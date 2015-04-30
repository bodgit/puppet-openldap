require 'pathname'
require 'set'

Puppet::Type.newtype(:openldap) do
  @doc = 'Manage openldap configuration objects'

  ensurable do
    defaultvalues
    defaultto(:present)
  end

  newparam(:name) do
    desc 'The distinguished name of the object'
    isnamevar
  end

  newproperty(:attributes) do
    desc 'The attributes of the object'

    munge do |value|
      raise Puppet::Error, 'Puppet::Type::Openldap: attributes must be a hash.' unless value.is_a? Hash

      # Ensure every value is an array
      value.each do |k,v|
        value[k] = [v] unless v.is_a?(Array)
      end

      # Prune any nils or zero-length values from each value array
      value.each do |k,v|
        v.reject! { |x| !x or x == :undef or x == '' }
      end

      # Prune any keys where the value is a zero-element array
      value.select! do |k,v|
        v.size > 0
      end

      value
    end

    def insync?(is)
      # Copy 'is' and 'should' and convert all of the keys to lower case
      a = Hash[is.collect { |k,v| [k.downcase, v] }]
      b = Hash[should.collect { |k,v| [k.downcase, v] }]

      case @resource[:purge]
      when :false
        # The keys in 'b' are a subset of the keys in 'a'
        return false unless a.keys.to_set.superset?(b.keys.to_set)
        b.keys.each do |k|
          # The value of each key in 'b' is a subset of the same value in 'a'
          return false unless a[k].to_set.superset?(b[k].to_set)
        end
      when :partial
        # The keys in 'b' are a subset of the keys in 'a'
        return false unless a.keys.to_set.superset?(b.keys.to_set)
        b.keys.each do |k|
          # The value of each key in 'b' must be equal to the same value in 'a'
          return false unless a[k].to_set == b[k].to_set
        end
      else
        # The keys in 'b' are equal to the keys in 'a'
        return false unless a.keys.to_set == b.keys.to_set
        b.keys.each do |k|
          # The value of each key in 'b' must be equal to the same value in 'a'
          return false unless a[k].to_set == b[k].to_set
        end
      end

      true
    end
  end

  newparam(:service) do
    desc 'The name of the slapd service'
    defaultto('slapd')
  end

  newparam(:purge) do
    desc 'Purge unmanaged attributes'
    newvalues(:true, :false, :partial)
    defaultto(:true)
  end

  newparam(:ldif) do
    desc 'LDIF file containing object to load'

    validate do |value|
      pn = Pathname.new value
      raise ArgumentError, 'The LDIF file must be fully qualified' unless pn.absolute?
    end
  end

  autorequire(:openldap) do
    autos = []

    if self[:ensure] == :present
      # If this resource should be present, autorequire the parent node or
      # the previous sibling if the DN uses the positional {x} notation. Prefer
      # the latter

      # A root node won't have a parent
      parent = self[:name].match(/(?<=,).+$/).to_s

      # In the case of a position create a regexp that matches the previous
      # sibling, i.e. 'cn={2}foo,ou=baz' produces /^cn=\{1\}[^,]+,ou=baz$/
      if self[:name] =~ (/^([^=]+)=\{(-?\d+)\}[^,]+/)
        sibling = /^#{$1}=\{#{$2.to_i - 1}\}[^,]+#{Regexp.escape($')}$/
      end

      auto = nil
      catalog.resources.select { |r|
        r.is_a?(Puppet::Type.type(:openldap)) and r.should(:ensure) == :present
      }.each { |r|
        auto ||= r if parent and r.name == parent
        auto = r if sibling and r.name =~ sibling
      }
      autos << auto if auto
    else
      # If this resource should be absent, autorequire any child nodes. Child
      # nodes that should be absent will therefore be removed first. Child
      # nodes that should be present will be created first and therefore 
      # trigger an error here as this node cannot now be removed
      catalog.resources.select { |r|
        r.is_a?(Puppet::Type.type(:openldap))
      }.select { |r|
        r.name =~ /^[^,]+,#{self[:name]}$/
      }.each { |r|
        autos << r
      }
    end

    autos
  end

  # Object attributes where the value is a file or directory
  FILE_ATTRIBUTES = [
    'olcargsfile',
    'olcdbdirectory',
    'olcpidfile',
    'olctlscacertificatefile',
    'olctlscacertificatepath',
    'olctlscertificatefile',
    'olctlscertificatekeyfile',
    'olctlsdhparamfile',
  ]

  autorequire(:file) do
    autos = []

    # Autorequire any file resource pointed at by the given attributes
    if self[:attributes]
      autos += self[:attributes].select { |k,v| FILE_ATTRIBUTES.include?(k.downcase) }.values.flatten
    end

    # Autorequire the LDIF file if passed
    if self[:ldif]
      autos << self[:ldif]
    end

    autos
  end

  autorequire(:service) do
    # Autorequire the slapd service otherwise modifications won't work
    [self[:service]]
  end
end
