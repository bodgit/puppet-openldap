# Flatten an array of ACL directives to an array of strings.
#
# @param values The array of ACL directives to flatten, `undef` is passed through.
#
# @return [Optional[Array[String, 1]]] The array of flattened strings.
#
# @example
#   openldap::flatten_access([[{'dn' => '*'}, [{'who' => ['*'], 'access' => 'none'}]]])
#
# @since 2.0.0
function openldap::flatten_access(Optional[Array[OpenLDAP::Access, 1]] $values) {

  $values ? {
    undef   => undef,
    default => $values.map |OpenLDAP::Access $value| {
      join([
        'to',
        join(delete_undef_values([
          $value[0]['dn'] ? {
            undef   => undef,
            default => $value[0]['dn'],
          },
          $value[0]['filter'] ? {
            undef   => undef,
            default => "filter=${value[0]['filter']}",
          },
          type($value[0]['attrs']) ? {
            Type[Scalar] => "attrs=${value[0]['attrs']}",
            Type[Array]  => "attrs=${join($value[0]['attrs'], ',')}",
            default      => undef,
          },
        ]), ' '),
        join($value[1].map |OpenLDAP::Access::By $x| {
          join(delete_undef_values([
            'by',
            join($x['who'], ' '),
            $x['access'] ? {
              undef   => undef,
              default => $x['access'],
            },
            $x['control'] ? {
              undef   => undef,
              default => $x['control'],
            },
          ]), ' ')
        }, ' '),
      ], ' ')
    }
  }
}
