# Flatten the proxy TLS specification to string form.
#
# @param value The TLS specification to flatten, `undef` is passed through.
#
# @return [Optional[String]] The flattened specification.
#
# @example
#   openldap::flatten_ldap_tls({'mode' => 'start', 'tls_cert' => '/tmp/cert.pem', 'tls_key' => '/tmp/key.pem'})
#
# @since 2.0.0
function openldap::flatten_ldap_tls(Optional[OpenLDAP::LDAP::TLS] $value) {

  $value ? {
    undef   => undef,
    default => join([$value['mode']] + $value.filter |$x| {
      $x[0] != 'mode'
    }.map |$x| {
      "${x[0]}=${x[1]}"
    }, ' ')
  }
}
