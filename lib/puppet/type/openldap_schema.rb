require 'set'
require 'uri'

Puppet::Type.newtype(:openldap_schema) do
  desc <<-DESC
Manages an OpenLDAP schema object.

@example Load the cosine schema
  include ::openldap::server

  openldap_schema { 'cosine':
    ensure => present,
    ldif   => '/etc/openldap/schema/cosine.ldif',
  }
DESC

  @doc = 'Manages an OpenLDAP schema object.'

  ensurable do
    defaultvalues
    defaultto(:present)
  end

  newparam(:name) do
    desc 'The name of the schema.'
    isnamevar
  end

  newparam(:service) do
    desc 'The name of the slapd service.'
    defaultto('slapd')
  end

  newparam(:ldif) do
    desc 'LDIF file containing schema to load.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        begin
          uri = URI.parse(URI.escape(value))
        rescue => detail
          raise Puppet::Error, "Could not understand LDIF #{value}: #{detail}"
        end

        raise Puppet::Error, "Cannot use relative URLs '#{value}'" unless uri.absolute?
        raise Puppet::Error, "Cannot use opaque URLs '#{value}'" unless uri.hierarchical?
        raise Puppet::Error, "Cannot use URLs of type '#{uri.scheme}' as source for fileserving" unless %w{file puppet}.include?(uri.scheme)
      end
    end

    SEPARATOR_REGEX = [Regexp.escape(File::SEPARATOR.to_s), Regexp.escape(File::ALT_SEPARATOR.to_s)].join

    munge do |value|
      ldif = value.sub(/[#{SEPARATOR_REGEX}]+$/, '')
      if Puppet::Util.absolute_path?(ldif)
        URI.unescape(Puppet::Util.path_to_uri(ldif).to_s)
      else
        ldif
      end
    end
  end

  autorequire(:openldap) do
    # Autorequire the parent schema object
    ['cn=schema,cn=config']
  end

  autobefore(:openldap) do
    # Autobefore the frontend database object
    ['olcDatabase={-1}frontend,cn=config']
  end

  autorequire(:file) do
    autos = []

    # Autorequire the LDIF file if passed and it's a local file
    if self[:ldif]
      if ldif = self[:ldif] and uri = URI.parse(URI.escape(ldif)) and uri.scheme == 'file'
        autos << uri_to_path(uri)
      end
    end

    autos
  end

  autorequire(:service) do
    # Autorequire the slapd service otherwise modifications won't work
    [self[:service]]
  end
end
