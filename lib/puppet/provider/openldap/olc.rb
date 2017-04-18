require 'tempfile'
require 'base64'

Puppet::Type.type(:openldap).provide(:olc) do
  desc 'Uses the dynamic OpenLDAP online configuration database to manage configuration objects.'

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

    o = slapcat '-b', 'cn=config', '-o', 'ldif-wrap=no', '-H', 'ldap:///???(!(entryDN:dnSubordinateMatch:=cn=schema,cn=config))'
    o.split("\n\n").collect do |object|
      name = nil
      attributes = {}
      object.split("\n").collect do |line|
        case line
        when /^dn: (.+)$/
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

  def flush
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

  def create
    @property_flush[:ensure] = :present
  end
end
