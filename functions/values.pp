# Transforms an array of values to include a `{x}` positional prefix for use as
# the values of an OpenLDAP object attribute requiring a fixed order.
#
# @param values The attribute values to transform, `undef` is passed through
#   unchanged.
#
# @return [Optional[Array[String]]] Prefixed attribute values.
#
# @example
#   openldap::values(['foo', 'bar'])
#
# @since 2.0.0
function openldap::values(Optional[Array[String]] $values) {

  $values ? {
    undef   => undef,
    default => $values.map |Integer $index, String $value| {
      "{${index}}${value}"
    },
  }
}
