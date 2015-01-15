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
      # If this resource should be present, autorequire the parent node

      # A root node won't have a parent
      parent = self[:name].match(/(?<=,).+$/).to_s

      catalog.resources.reject { |r|
        ! r.is_a?(Puppet::Type.type(:openldap))
      }.select { |r|
        parent and parent == r.name and r.should(:ensure) == :present
      }.each { |r|
        autos << r
      }
    else
      # If this resource should be absent, autorequire any child nodes. Child
      # nodes that should be absent will therefore be removed first. Child
      # nodes that should be present will be created first and therefore 
      # trigger an error here as this node cannot now be removed
      catalog.resources.reject { |r|
        ! r.is_a?(Puppet::Type.type(:openldap))
      }.select { |r|
        r.name =~ /^[^,]+,#{self[:name]}$/
      }.each { |r|
        autos << r
      }
    end

    autos
  end

  autorequire(:service) do
    # Autorequire the slapd service otherwise modifications won't work
    [self[:service]]
  end
end
