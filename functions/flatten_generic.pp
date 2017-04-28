# Flatten a generic list attribute to a string.
#
# @param values The list to flatten, `undef` is passed through.
#
# @return [Optional[String]] The flattened list as a string.
#
# @example
#   openldap::flatten_generic([1, 'foo', 3])
#
# @since 2.0.0
function openldap::flatten_generic(Optional[Array[Variant[Numeric, String], 1]] $values) {

  $values ? {
    undef   => undef,
    default => join($values, ' '),
  }
}
