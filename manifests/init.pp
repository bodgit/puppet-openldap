# Installs base LDAP library and global client configuration file.
#
# @example Declaring the class and mimicking the default global configuration on RHEL/CentOS
#   class { '::openldap':
#     tls_cacertdir => '/etc/openldap/certs'
#   }
#
# @param package_name The name of the package.
# @param conf_dir Top-level configuration directory, usually `/etc/openldap`.
# @param ldap_conf_file The global client configuration file, usually
#   `${conf_dir}/ldap.conf`.
# @param base See the `openldap::configuration` defined type.
# @param uri See the `openldap::configuration` defined type.
# @param deref See the `openldap::configuration` defined type.
# @param network_timeout See the `openldap::configuration` defined type.
# @param referrals See the `openldap::configuration` defined type.
# @param sizelimit See the `openldap::configuration` defined type.
# @param timelimit See the `openldap::configuration` defined type.
# @param timeout See the `openldap::configuration` defined type.
# @param sasl_secprops See the `openldap::configuration` defined type.
# @param sasl_nocanon See the `openldap::configuration` defined type.
# @param gssapi_sign See the `openldap::configuration` defined type.
# @param gssapi_encrypt See the `openldap::configuration` defined type.
# @param gssapi_allow_remote_principal See the `openldap::configuration`
#   defined type.
# @param tls_cacert See the `openldap::configuration` defined type.
# @param tls_cacertdir See the `openldap::configuration` defined type.
# @param tls_cipher_suite See the `openldap::configuration` defined type.
# @param tls_moznss_compatibility See the `openldap::configuration` defined type.
# @param tls_protocol_min See the `openldap::configuration` defined type.
# @param tls_randfile See the `openldap::configuration` defined type.
# @param tls_reqcert See the `openldap::configuration` defined type.
# @param tls_crlcheck See the `openldap::configuration` defined type.
# @param tls_crlfile See the `openldap::configuration` defined type.
#
# @see puppet_classes::openldap::client ::openldap::client
# @see puppet_defined_types::openldap::configuration ::openldap::configuration
class openldap (
  String               $package_name                  = $::openldap::params::base_package_name,
  Stdlib::Absolutepath $conf_dir                      = $::openldap::params::conf_dir,
  Stdlib::Absolutepath $ldap_conf_file                = $::openldap::params::ldap_conf_file,
  # All of these are passed through to ::openldap::configuration
  Any                  $base                          = undef,
  Any                  $uri                           = undef,
  Any                  $deref                         = undef,
  Any                  $network_timeout               = undef,
  Any                  $referrals                     = undef,
  Any                  $sizelimit                     = undef,
  Any                  $timelimit                     = undef,
  Any                  $timeout                       = undef,
  Any                  $sasl_secprops                 = undef,
  Any                  $sasl_nocanon                  = undef,
  Any                  $gssapi_sign                   = undef,
  Any                  $gssapi_encrypt                = undef,
  Any                  $gssapi_allow_remote_principal = undef,
  Any                  $tls_cacert                    = undef,
  Any                  $tls_cacertdir                 = undef,
  Any                  $tls_cipher_suite              = undef,
  Any                  $tls_moznss_compatibility      = undef,
  Any                  $tls_protocol_min              = undef,
  Any                  $tls_randfile                  = undef,
  Any                  $tls_reqcert                   = undef,
  Any                  $tls_crlcheck                  = undef,
  Any                  $tls_crlfile                   = undef,
) inherits ::openldap::params {

  contain ::openldap::install
  contain ::openldap::config

  Class['::openldap::install'] -> Class['::openldap::config']
}
