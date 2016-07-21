#
# openldap_unique_indices.rb
#

module Puppet::Parser::Functions
  newfunction(:openldap_unique_indices, :type => :rvalue, :doc => <<-EOS
Takes an array of olcDbIndex attributes, and outputs an array of olcDbIndex
attributes where each is unique (e.g. there are no repeated indices).

*Example:*

  openldap_unique_indices(['entryCSN,entryUUID eq', 'ou,cn eq,pres,sub', 'entryCSN eq', 'entryUUID eq'])

Would result in:

  ['entryCSN eq', 'entryUUID eq', 'ou eq,pres,sub', 'cn eq,pres,sub']

EOS
  ) do |arguments|

    raise(Puppet::ParseError, 'size(): Wrong number of arguments ' +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    indices = arguments[0]

    unless indices.is_a?(Array)
      raise(Puppet::ParseError, 'openldap_unique_indices(): Requires an ' +
        'array to work with')
    end

    separate_indices = indices.reduce([]) { |memo, i|
      index_parts = i.split
      memo + index_parts[0].split(",").map { |attr|
        "#{attr} #{index_parts[1]}"
      }
    }

    return separate_indices.uniq
  end
end
