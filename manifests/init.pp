#
class openldap (
  $package_name                  = $::openldap::params::base_package_name,
  $conf_dir                      = $::openldap::params::conf_dir,
  $ldap_conf_file                = $::openldap::params::ldap_conf_file,
  $base                          = undef,
  $uri                           = undef,
  $deref                         = undef,
  $network_timeout               = undef,
  $referrals                     = undef,
  $sizelimit                     = undef,
  $timelimit                     = undef,
  $timeout                       = undef,
  # sasl
  $sasl_secprops                 = undef,
  $sasl_nocanon                  = undef,
  # gssapi
  $gssapi_sign                   = undef,
  $gssapi_encrypt                = undef,
  $gssapi_allow_remote_principal = undef,
  # tls
  $tls_cacert                    = undef,
  $tls_cacertdir                 = undef,
  $tls_cipher_suite              = undef,
  $tls_protocol_min              = undef,
  $tls_randfile                  = undef,
  $tls_reqcert                   = undef,
  $tls_crlcheck                  = undef,
  $tls_crlfile                   = undef,
) inherits ::openldap::params {

  validate_absolute_path($conf_dir)
  validate_absolute_path($ldap_conf_file)

  include ::openldap::install
  include ::openldap::config

  anchor { 'openldap::begin': }
  anchor { 'openldap::end': }

  Anchor['openldap::begin'] -> Class['::openldap::install']
    -> Class['::openldap::config'] -> Anchor['openldap::end']
}
