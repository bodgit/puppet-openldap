#
define openldap::configuration (
  $ensure,
  $owner,
  $group,
  $mode,
  $base                          = undef,
  $uri                           = undef,
  $binddn                        = undef,
  $deref                         = undef,
  $network_timeout               = undef,
  $referrals                     = undef,
  $sizelimit                     = undef,
  $timelimit                     = undef,
  $timeout                       = undef,
  # sasl
  $sasl_mech                     = undef,
  $sasl_realm                    = undef,
  $sasl_authcid                  = undef,
  $sasl_authzid                  = undef,
  $sasl_secprops                 = undef,
  $sasl_nocanon                  = undef,
  # gssapi
  $gssapi_sign                   = undef,
  $gssapi_encrypt                = undef,
  $gssapi_allow_remote_principal = undef,
  # tls
  $tls_cacert                    = undef,
  $tls_cacertdir                 = undef,
  $tls_cert                      = undef,
  $tls_key                       = undef,
  $tls_cipher_suite              = undef,
  $tls_protocol_min              = undef,
  $tls_randfile                  = undef,
  $tls_reqcert                   = undef,
  $tls_crlcheck                  = undef,
  $tls_crlfile                   = undef,
) {

  if ! defined(Class['::openldap']) {
    fail('You must include the openldap base class before using any openldap defined resources') # lint:ignore:80chars
  }

  validate_re($ensure, '^(?:file|present|absent)$')

  if $base {
    validate_string($base)
    validate_ldap_dn($base)
  }
  if $uri {
    validate_array($uri)
    validate_ldap_uri($uri)
  }
  if $binddn {
    validate_string($binddn)
    validate_ldap_dn($binddn)
  }
  if $deref {
    validate_re($deref, '^(?:never|searching|finding|always)$')
  }
  if $network_timeout {
    validate_integer($network_timeout)
  }
  if $referrals {
    validate_bool($referrals)
  }
  if $sizelimit {
    validate_integer($sizelimit)
  }
  if $timelimit {
    validate_integer($timelimit)
  }
  if $timeout {
    validate_integer($timeout)
  }
  if $sasl_mech {
    validate_string($sasl_mech)
  }
  if $sasl_realm {
    validate_string($sasl_realm)
  }
  if $sasl_authcid {
    validate_string($sasl_authcid)
  }
  if $sasl_authzid {
    validate_string($sasl_authzid)
  }
  if $sasl_secprops {
    validate_array($sasl_secprops)
  }
  if $sasl_nocanon {
    validate_bool($sasl_nocanon)
  }
  if $gssapi_sign {
    validate_bool($gssapi_sign)
  }
  if $gssapi_encrypt {
    validate_bool($gssapi_encrypt)
  }
  if $gssapi_allow_remote_principal {
    validate_bool($gssapi_allow_remote_principal)
  }
  if $tls_cacert {
    validate_absolute_path($tls_cacert)
  }
  if $tls_cacertdir {
    validate_absolute_path($tls_cacertdir)
  }
  if $tls_cert {
    validate_absolute_path($tls_cert)
  }
  if $tls_key {
    validate_absolute_path($tls_key)
  }
  if $tls_cipher_suite {
    validate_string($tls_cipher_suite)
  }
  if $tls_protocol_min {
    validate_number($tls_protocol_min)
  }
  if $tls_randfile {
    validate_absolute_path($tls_randfile)
  }
  if $tls_reqcert {
    validate_re($tls_reqcert, '^(?:never|allow|try|demand|hard)$')
  }
  if $tls_crlcheck {
    validate_re($tls_crlcheck, '^(?:none|peer|all)$')
  }
  if $tls_crlfile {
    validate_absolute_path($tls_crlfile)
  }

  file { $name:
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template('openldap/ldap.conf.erb'),
  }
}
