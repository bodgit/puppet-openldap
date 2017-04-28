# Flatten the proxy authentication specification to string form.
#
# @param value The specification to flatten, `undef` is passed through.
#
# @return [Optional[String]] The flattened specification.
#
# @example
#   openldap::flatten_ldap_id_assert_bind({'bindmethod' => 'simple', 'binddn' => 'cn=Manager,dc=example,dc=com'})
#
# @since 2.0.0
function openldap::flatten_ldap_id_assert_bind(Optional[OpenLDAP::LDAP::IDAssertBind] $value) {

  $value ? {
    undef   => undef,
    default => join($value.map |$x| {
      case $x[0] {
        'binddn': {
          "${x[0]}=\"${x[1]}\""
        }
        'flags': {
          "${x[0]}=${join($x[1], ',')}"
        }
        default: {
          "${x[0]}=${x[1]}"
        }
      }
    }, ' '),
  }
}
