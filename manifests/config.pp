# @!visibility private
class openldap::config {

  file { $::openldap::conf_dir:
    ensure => directory,
    owner  => 0,
    group  => 0,
    mode   => '0644',
  }

  ::openldap::configuration { $::openldap::ldap_conf_file:
    ensure                        => file,
    owner                         => 0,
    group                         => 0,
    mode                          => '0644',
    base                          => $::openldap::base,
    uri                           => $::openldap::uri,
    deref                         => $::openldap::deref,
    network_timeout               => $::openldap::network_timeout,
    referrals                     => $::openldap::referrals,
    sizelimit                     => $::openldap::sizelimit,
    timelimit                     => $::openldap::timelimit,
    timeout                       => $::openldap::timeout,
    sasl_secprops                 => $::openldap::sasl_secprops,
    sasl_nocanon                  => $::openldap::sasl_nocanon,
    gssapi_sign                   => $::openldap::gssapi_sign,
    gssapi_encrypt                => $::openldap::gssapi_encrypt,
    gssapi_allow_remote_principal => $::openldap::gssapi_allow_remote_principal,
    tls_cacert                    => $::openldap::tls_cacert,
    tls_cacertdir                 => $::openldap::tls_cacertdir,
    tls_cipher_suite              => $::openldap::tls_cipher_suite,
    tls_protocol_min              => $::openldap::tls_protocol_min,
    tls_randfile                  => $::openldap::tls_randfile,
    tls_reqcert                   => $::openldap::tls_reqcert,
    tls_crlcheck                  => $::openldap::tls_crlcheck,
    tls_crlfile                   => $::openldap::tls_crlfile,
  }
}
