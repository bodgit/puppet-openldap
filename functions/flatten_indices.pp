# Flatten an array of index directives to an array of strings.
#
# @param values The array of index directives.
#
# @return [Optional[Array[String, 1]]] The array of flattened strings.
#
# @example
#   openldap::flatten_indices([[['entryCSN', 'entryUUID'], ['eq']]])
#
# @since 2.0.0
function openldap::flatten_indices(Optional[Array[OpenLDAP::Index, 1]] $values) {

  $values ? {
    undef   => undef,
    default => $values.map |OpenLDAP::Index $value| {
      size($value) ? {
        1       => "${join($value[0], ',')}",
        default => "${join($value[0], ',')} ${join($value[1], ',')}",
      }
    }
  }
}
