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
        if ! v.is_a?(Array)
          value[k] = [v]
        end
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
      # is and should can present keys in differing order which throws the
      # comparison off. The values should be sorted too. Keys should be
      # converted to lowercase as well
      a = Hash[is.sort_by { |k,v| k.downcase }.collect { |k,v| [k.downcase, v] }]
      b = Hash[should.sort_by { |k,v| k.downcase }.collect { |k,v| [k.downcase, v] }]

      a.keys.each do |k|
        a[k] = a[k].sort
      end
      b.keys.each do |k|
        b[k] = b[k].sort
      end

      a == b
    end
  end

  newparam(:service) do
    desc 'The name of the slapd service'
    defaultto('slapd')
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

  autorequire(:file) do
    # Autorequire the file resource used by the database backend
    if self[:attributes]
      self[:attributes].select { |k,v| k =~ /^olcDbDirectory$/i }.values.flatten
    else
      []
    end
  end

  autorequire(:service) do
    # Autorequire the slapd service otherwise modifications won't work
    [self[:service]]
  end
end
