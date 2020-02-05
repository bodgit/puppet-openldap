# Handles creating global or per-user LDAP client configuration.
#
# @example Create a per-user `~/.ldaprc` for any subsequently created users
#   ::openldap::configuration { '/etc/skel/.ldaprc':
#     ensure => file,
#     owner  => 0,
#     group  => 0,
#     mode   => '0640',
#     base   => 'dc=example,dc=com',
#     uri    => ['ldap://ldap.example.com/'],
#   }
#
#   ::Openldap::Configuration['/etc/skel/.ldaprc'] -> User <||>
#
# @param ensure See `file` resource type.
# @param owner See `file` resource type.
# @param group See `file` resource type.
# @param mode See `file` resource type.
# @param file The path to the configuration file.
# @param base Maps to the `BASE` `ldap.conf` option.
# @param uri Maps to the `URI` `ldap.conf` option.
# @param binddn Maps to the `BINDDN` `ldap.conf` option.
# @param deref Maps to the `DEREF` `ldap.conf` option.
# @param network_timeout Maps to the `NETWORK_TIMEOUT` `ldap.conf` option.
# @param referrals Maps to the `REFERRALS` `ldap.conf` option.
# @param sizelimit Maps to the `SIZELIMIT` `ldap.conf` option.
# @param timelimit Maps to the `TIMELIMIT` `ldap.conf` option.
# @param timeout Maps to the `TIMEOUT` `ldap.conf` option.
# @param sasl_mech Maps to the `SASL_MECH` `ldap.conf` option.
# @param sasl_realm Maps to the `SASL_REALM` `ldap.conf` option.
# @param sasl_authcid Maps to the `SASL_AUTHCID` `ldap.conf` option.
# @param sasl_authzid Maps to the `SASL_AUTHZID` `ldap.conf` option.
# @param sasl_secprops Maps to the `SASL_SECPROPS` `ldap.conf` option.
# @param sasl_nocanon Maps to the `SASL_NOCANON` `ldap.conf` option.
# @param gssapi_sign Maps to the `GSSAPI_SIGN` `ldap.conf` option.
# @param gssapi_encrypt Maps to the `GSSAPI_ENCRYPT` `ldap.conf` option.
# @param gssapi_allow_remote_principal Maps to the `GSSAPI_ALLOW_REMOTE_PRINCIPAL` `ldap.conf` option.
# @param tls_cacert Maps to the `TLS_CACERT` `ldap.conf` option.
# @param tls_cacertdir Maps to the `TLS_CACERTDIR` `ldap.conf` option.
# @param tls_cert Maps to the `TLS_CERT` `ldap.conf` option.
# @param tls_key Maps to the `TLS_KEY` `ldap.conf` option.
# @param tls_cipher_suite Maps to the `TLS_CIPHER_SUITE` `ldap.conf` option.
# @param tls_moznss_compatibility Maps to the `TLS_MOZNSS_COMPATIBILITY` `ldap.conf` option.
# @param tls_protocol_min Maps to the `TLS_PROTOCOL_MIN` `ldap.conf` option.
# @param tls_randfile Maps to the `TLS_RANDFILE` `ldap.conf` option.
# @param tls_reqcert Maps to the `TLS_REQCERT` `ldap.conf` option.
# @param tls_crlcheck Maps to the `TLS_CRLCHECK` `ldap.conf` option.
# @param tls_crlfile Maps to the `TLS_CRLFILE` `ldap.conf` option.
#
# @see puppet_classes::openldap ::openldap
# @see puppet_classes::openldap::client ::openldap::client
define openldap::configuration (
  Enum['file', 'present', 'absent']                         $ensure,
  Variant[String[1], Integer[0]]                            $owner,
  Variant[String[1], Integer[0]]                            $group,
  String                                                    $mode,
  Stdlib::Absolutepath                                      $file                          = $title,
  Optional[Bodgitlib::LDAP::DN]                             $base                          = undef,
  Optional[Array[Bodgitlib::LDAP::URI::Simple, 1]]          $uri                           = undef,
  Optional[Bodgitlib::LDAP::DN]                             $binddn                        = undef,
  Optional[Enum['never', 'searching', 'finding', 'always']] $deref                         = undef,
  Optional[Integer[0]]                                      $network_timeout               = undef,
  Optional[Boolean]                                         $referrals                     = undef,
  Optional[Integer[0]]                                      $sizelimit                     = undef,
  Optional[Integer[0]]                                      $timelimit                     = undef,
  Optional[Integer[0]]                                      $timeout                       = undef,
  # sasl
  Optional[String]                                          $sasl_mech                     = undef,
  Optional[String]                                          $sasl_realm                    = undef,
  Optional[String]                                          $sasl_authcid                  = undef,
  Optional[String]                                          $sasl_authzid                  = undef,
  Optional[Array[String, 1]]                                $sasl_secprops                 = undef,
  Optional[Boolean]                                         $sasl_nocanon                  = undef,
  # gssapi
  Optional[Boolean]                                         $gssapi_sign                   = undef,
  Optional[Boolean]                                         $gssapi_encrypt                = undef,
  Optional[Boolean]                                         $gssapi_allow_remote_principal = undef,
  # tls
  Optional[Stdlib::Absolutepath]                            $tls_cacert                    = undef,
  Optional[Stdlib::Absolutepath]                            $tls_cacertdir                 = undef,
  Optional[Stdlib::Absolutepath]                            $tls_cert                      = undef,
  Optional[Stdlib::Absolutepath]                            $tls_key                       = undef,
  Optional[String]                                          $tls_cipher_suite              = undef,
  Optional[Boolean]                                         $tls_moznss_compatibility      = undef,
  Optional[Variant[Integer[0], Float[0]]]                   $tls_protocol_min              = undef,
  Optional[Stdlib::Absolutepath]                            $tls_randfile                  = undef,
  Optional[Enum['never', 'allow', 'try', 'demand', 'hard']] $tls_reqcert                   = undef,
  Optional[Enum['none', 'peer', 'all']]                     $tls_crlcheck                  = undef,
  Optional[Stdlib::Absolutepath]                            $tls_crlfile                   = undef,
) {

  if ! defined(Class['::openldap']) {
    fail('You must include the openldap base class before using any openldap defined resources')
  }

  file { $file:
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template("${module_name}/ldap.conf.erb"),
  }
}
