require 'tempfile'
require 'base64'
require 'uri'
require 'puppet/network/http/compression'

if Puppet::PUPPETVERSION.split('.').first.to_i < 4
  require 'puppet/network/http/api/v1'
else
  require 'puppet/network/http/api/indirected_routes'
end

Puppet::Type.type(:openldap).provide(:olc) do
  include Puppet::Network::HTTP::Compression.module

  commands :slapcat => 'slapcat', :ldapmodify => 'ldapmodify'

  mk_resource_methods

  EXCLUDED = [
    'contextCSN',
    'createTimestamp',
    'creatorsName',
    'entryCSN',
    'entryUUID',
    'modifiersName',
    'modifyTimestamp',
    'structuralObjectClass',
  ]

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.instances

    o = slapcat '-b', 'cn=config', '-o', 'ldif-wrap=no', '-H', 'ldap:///???'
    o.split("\n\n").collect do |object|
      name = nil
      attributes = {}
      object.split("\n").collect do |line|
        case line
        when /^dn: (.*)$/
          name = $1
        else
          k, encoded, v = line.match(/^([^:]+):(:)? (.*)$/).captures

          # Don't include "internal" attributes
          next if EXCLUDED.include?(k)

          # If we matched a second ':' it means the value is base64-encoded
          if encoded
            v = Base64.decode64(v)
          end

          attributes[k] ||= []
          attributes[k] << v
        end
      end

      new(:name => name, :ensure => :present, :attributes => attributes)
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.prefetch(resources)
    instances.each do |provider|
      if resource = resources[provider.name]
        resource.provider = provider
      end
    end
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def attributes=(value)
    @property_flush[:attributes] = value
  end

  def metadata(source)
    metadata = nil
    environment = resource.catalog.respond_to?(:environment_instance) ? resource.catalog.environment_instance : resource.catalog.environment
    begin
      if metadata = Puppet::FileServing::Metadata.indirection.find(source, :environment => environment, :links => :follow)
        metadata.source = source
      end
    rescue => detail
      self.fail Puppet::Error, "Could not retrieve file metadata for #{source}: #{detail}", detail
    end
    self.fail "Could not retrieve information from environment #{environment} source #{source}" unless metadata
    metadata
  end

  def puppet_source_to_path(source)
    environment = resource.catalog.respond_to?(:environment_instance) ? resource.catalog.environment_instance : resource.catalog.environment

    metadata = metadata(source)

    if Puppet[:default_file_terminus] == :file_server
      if file = Puppet::FileServing::Content.indirection.find(metadata.source, :environment => environment, :links => :follow)
        file.path
      else
        self.fail "Could not find any content at #{metadata.source}"
      end
    else
      temp = Tempfile.new('openldap.ldif')
      request = Puppet::Indirector::Request.new(:file_content, :find, metadata.source, nil, :environment => environment)
      request.do_request(:fileserver) do |req|

        connection = Puppet::Network::HttpPool.http_instance(req.server, req.port)
        format = Puppet::FileServing::Content.supported_formats.include?(:binary) ? 'binary' : 'raw'
        uri = if defined?(Puppet::Network::HTTP::API::IndirectedRoutes)
          Puppet::Network::HTTP::API::IndirectedRoutes.request_to_uri(req)
        else
          Puppet::Network::HTTP::API::V1.indirection2uri(req)
        end

        connection.request_get(uri, add_accept_encoding({'Accept' => format})) do |response|
          if response.code =~ /^2/
            uncompress(response) do |uncompressor|
              response.read_body do |chunk|
                temp << uncompressor.uncompress(chunk)
              end
            end
          else
            message = "Error #{response.code} on SERVER: #{(response.body || '').empty? ? response.message : uncompress_body(response)}"
            raise Net::HTTPError.new(message, response)
          end
        end
      end
      temp.close
      temp.path
    end
  end

  def path(source)
    uri = URI.parse(URI.escape(source))
    case uri.scheme
    when 'file'
      uri_to_path(uri)
    when 'puppet'
      puppet_source_to_path(source)
    else
      source
    end
  end

  def flush
    if @property_flush[:ensure] == :present and resource[:ldif] then
      ldapmodify '-Y', 'EXTERNAL', '-H', 'ldapi:///', '-a', '-f', path(resource[:ldif])
    else
      begin
        temp = Tempfile.new("openldap.#{resource[:name]}")
        temp << "dn: #{resource[:name]}\n"

        case @property_flush[:ensure]
        when :absent
          temp << "changetype: delete\n"
        when :present
          temp << "changetype: add\n"
          resource[:attributes].each do |k,values|
            values.each do |v|
              temp << "#{k}: #{v}\n"
            end
          end
        end

        if @property_flush[:attributes]
          temp << "changetype: modify\n"

          is = @property_hash[:attributes].keys
          should = @property_flush[:attributes].keys
          ops = []

          # Remove any attributes that shouldn't exist at all
          if resource[:purge] == :true
            (is - should).each do |k|
              ops << "delete: #{k}\n"
            end
          end

          # Add any attributes that didn't exist at all and now should
          (should - is).each do |k|
            op = "add: #{k}\n"
            @property_flush[:attributes][k].each do |v|
              op << "#{k}: #{v}\n"
            end
            ops << op
          end

          # Now deal with attributes that already exist in some form
          (should & is).each do |k|
            isv = @property_hash[:attributes][k].sort
            shouldv = @property_flush[:attributes][k].sort

            # No differences, skip
            #next if isv == shouldv

            # If there's no overlap in values, use replace instead of add/delete
            if (isv & shouldv).size == 0 and resource[:purge] != :false
              op = "replace: #{k}\n"
              shouldv.each do |v|
                op << "#{k}: #{v}\n"
              end
              ops << op
              next
            end

            # Some values are deleted
            if (isv - shouldv).size > 0 and resource[:purge] != :false
              op = "delete: #{k}\n"
              (isv - shouldv).each do |v|
                op << "#{k}: #{v}\n"
              end
              ops << op
            end

            # Some values are added
            if (shouldv - isv).size > 0
              op = "add: #{k}\n"
              (shouldv - isv).each do |v|
                op << "#{k}: #{v}\n"
              end
              ops << op
            end
          end

          # Separate each LDIF operation with a '-'
          temp << ops.join("-\n")
        end

        temp.rewind
        Puppet.debug(IO.read temp.path)
        ldapmodify '-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', temp.path
      ensure
        temp.close
        temp.unlink
      end
    end
  end

  def create
    @property_flush[:ensure] = :present
  end
end
