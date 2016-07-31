#
# validate_openldap_unique_uri.rb
#

require 'uri/ldap'

module Puppet::Parser::Functions
  newfunction(:validate_openldap_unique_uri, :doc => <<-EOS
    Validate that all passed values are all valid unique URI specifications
    for the unique overlay. A base distinguished name is used to validate
    that any distinguished name in any URI is either an exact match or a
    subtree.

    Example:

      validate_openldap_unique_uri('dc=example,dc=com', ['ldap:///ou=people,dc=example,dc=com?uidNumber?sub'])
      validate_openldap_unique_uri('dc=example,dc=com', ['strict ldap:///ou=people,dc=example,dc=com?uidNumber?sub'])
      validate_openldap_unique_uri('dc=example,dc=com', ['ignore ldap:///ou=people,dc=example,dc=com?uidNumber?sub'])
    EOS
  ) do |arguments|

    raise Puppet::ParseError, 'validate_openldap_unique_uri(): Wrong number ' +
      "of arguments given (#{arguments.size} for 2)" if arguments.size != 2

    base = arguments[0]
    item = arguments[1]

    function_validate_ldap_dn([base])

    unless item.is_a?(Array)
      raise(Puppet::ParseError, 'validate_openldap_unique_uri(): Requires ' +
        'an array to work with')
    end

    if item.size == 0
      raise Puppet::ParseError, 'validate_openldap_unique_uri(): Requires ' +
        'an array with at least 1 element'
    end

    item.each do |i|
      unless i.is_a?(String)
        raise Puppet::ParseError, 'validate_openldap_unique_uri(): Requires ' +
          'either an array or string to work with'
      end

      begin
        if i =~ /^ (?:strict\s+)? (?:ignore\s+)? (.+) $/x
          $1.scan(/\S+/).each do |x|
            function_validate_ldap_uri([x])
            u = URI(x)
            if u.dn and u.dn.length > 0
              function_validate_ldap_sub_dn([base, u.dn])
            end
          end
        else
          raise
        end
      rescue
        raise Puppet::ParseError, 'validate_openldap_unique_uri(): ' +
          "'#{i.inspect}' is not a valid unique URI"
      end
    end
  end
end
