#
# openldap_values.rb
#

module Puppet::Parser::Functions
  newfunction(:openldap_values, :type => :rvalue, :doc => <<-EOS
Transforms an array of values to include a {x} positional prefix for use as
the values of an OpenLDAP object attribute requiring a fixed order.

*Example:*

    openldap_values(['foo','bar','baz'])

Would result in:

    ['{0}foo', '{1}bar', '{2}baz']
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, 'size(): Wrong number of arguments ' +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    item = arguments[0]

    unless item.is_a?(Array) || item.is_a?(String)
      raise(Puppet::ParseError, 'openldap_values(): Requires either ' +
        'array or string to work with')
    end

    if item.is_a?(String)
      item = [item]
    end

    return item.reject { |x| x.nil? or x.eql?('') }.each_with_index.collect { |x,i| "{#{i}}#{x}" }
  end
end

# vim: set ts=2 sw=2 et :
