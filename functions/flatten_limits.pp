# Flatten an array of combined size and time limit specifications to an array of strings.
#
# @param values The array of limits to flatten, `undef` is passed through.
#
# @return [Optional[Array[String, 1]]] The array of flattened strings.
#
# @example
#   openldap::flatten_limits([{'selector' => 'users', 'size' => 'unlimited', 'time' => 'unlimited'}])
#
# @since 2.0.0
function openldap::flatten_limits(Optional[Array[OpenLDAP::Limit, 1]] $values) {

  $values ? {
    undef   => undef,
    default => $values.map |OpenLDAP::Limit $value| {
      join(delete_undef_values([
        $value['selector'],
        type($value['size']) ? {
          Type[Scalar] => "size=${value['size']}",
          default      => openldap::flatten_size_limit($value['size']),
        },
        type($value['time']) ? {
          Type[Scalar] => "time=${value['time']}",
          default      => openldap::flatten_time_limit($value['time']),
        },
      ]), ' ')
    }
  }
}
