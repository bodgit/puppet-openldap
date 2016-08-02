#
# openldap_boolean.rb
#

module Puppet::Parser::Functions
  newfunction(:openldap_boolean, :type => :rvalue, :doc => <<-EOS

    Example:

      openldap_boolean(true)
      openldap_boolean(false)
      openldap_boolean(undef)
    EOS
  ) do |arguments|

    raise Puppet::ParseError, 'openldap_boolean(): Wrong number ' +
      "of arguments given (#{arguments.size} for 1)" if arguments.size != 1

    item = arguments[0]

    return nil if item.nil? or item.eql?('')

    unless [true, false].include?(item)
      raise Puppet::ParseError, 'openldap_boolean(): ' +
        "#{item.inspect} is not a boolean"
    end

    return item.to_s.upcase
  end
end
