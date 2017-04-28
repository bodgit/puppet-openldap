# Flatten an array of unique overlay uniqueness domains to an array of strings.
#
# @param values The array of domains to flatten, `undef` is passed through.
#
# @return [Optional[Array[String, 1]]] The array of flattened domains.
#
# @example
#   openldap::flatten_unique({'uri' => ['ldap:///?uidNumber?sub']})
#
# @since 2.0.0
function openldap::flatten_unique(Optional[Array[OpenLDAP::Unique, 1]] $values) {

  $values ? {
    undef   => undef,
    default => $values.map |OpenLDAP::Unique $value| {
      join(delete_undef_values([
        $value['strict'] ? {
          true    => 'strict',
          default => undef,
        },
        $value['ignore'] ? {
          true    => 'ignore',
          default => undef,
        },
        join($value['uri'], ' '),
      ]), ' ')
    }
  }
}
