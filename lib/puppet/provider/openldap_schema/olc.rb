require 'tempfile'
require 'base64'
require 'uri'
require 'puppet/network/http/compression'

if Puppet::PUPPETVERSION.split('.').first.to_i < 4
  require 'puppet/network/http/api/v1'
else
  require 'puppet/network/http/api/indirected_routes'
end

Puppet::Type.type(:openldap_schema).provide(:olc) do
  desc 'Uses the dynamic OpenLDAP online configuration database to manage schema objects.'

  include Puppet::Network::HTTP::Compression.module

  commands :slapcat => 'slapcat', :ldapmodify => 'ldapmodify'

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.instances

    o = slapcat '-b', 'cn=config', '-o', 'ldif-wrap=no', '-H', 'ldap:///???(entryDN:dnSubordinateMatch:=cn=schema,cn=config)'
    o.split("\n\n").collect do |object|
      name = nil
      object.split("\n").each do |line|
        case line
        when /^dn: cn=\{\d+\}([^,]+),cn=schema,cn=config$/
          name = $1
        end
      end

      new(:name => name, :ensure => :present)
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
      temp = Tempfile.new('openldap_schema.ldif')
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
    case @property_flush[:ensure]
    when :present
      ldapmodify '-Y', 'EXTERNAL', '-H', 'ldapi:///', '-a', '-f', path(resource[:ldif])
    when :absent
      begin
        temp = Tempfile.new("openldap_schema.#{resource[:name]}")
        temp << "dn: cn=#{resource[:name]},cn=schema,cn=config\n"
        temp << "changetype: delete\n"
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
