# @!visibility private
class openldap::params {

  $auditlog_file       = undef
  $ldap_interfaces     = ['']
  $ldaps_interfaces    = []
  $local_ssf           = 256
  $log_level           = undef
  $module_extension    = '.la'
  $password_modules    = {
    '{SHA256}'        => 'pw-sha2',
    '{SHA384}'        => 'pw-sha2',
    '{SHA512}'        => 'pw-sha2',
    '{SSHA256}'       => 'pw-sha2',
    '{SSHA384}'       => 'pw-sha2',
    '{SSHA512}'       => 'pw-sha2',
    '{TOTP1}'         => 'pw-totp',
    '{TOTP256}'       => 'pw-totp',
    '{TOTP512}'       => 'pw-totp',
    '{PBKDF2}'        => 'pw-pbkdf2',
    '{PBKDF2-SHA1}'   => 'pw-pbkdf2',
    '{PBKDF2-SHA256}' => 'pw-pbkdf2',
    '{PBKDF2-SHA512}' => 'pw-pbkdf2',
    '{BSDMD5}'        => 'pw-apr1',
    '{APR1}'          => 'pw-apr1',
    '{NS-MTA-MD5}'    => 'pw-netscape',
    '{RADIUS}'        => 'pw-radius',
    '{KERBEROS}'      => 'pw-kerberos',
  }
  $password_packages   = {}
  $ssl_ca              = undef
  $ssl_cert            = undef
  $ssl_certs_dir       = undef
  $ssl_cipher          = undef
  $ssl_dhparam         = undef
  $ssl_key             = undef
  $ssl_protocol        = undef
  $syncprov_checkpoint = '100 10'
  $syncprov_sessionlog = 100
  $unique_uri          = undef

  case $::osfamily {
    'RedHat': {
      $args_file           = '/var/run/openldap/slapd.args'
      $backend_modules     = [
        'dnssrv',
        'ldap',
        'meta',
        'null',
        'passwd',
        'perl',
        'relay',
        'shell',
        'sock',
        'sql',
      ]
      $backend_packages    = {
        'sql' => 'openldap-servers-sql',
      }
      $base_package_name   = 'openldap'
      $client_package_name = 'openldap-clients'
      $conf_dir            = '/etc/openldap'
      $data_directory      = '/var/lib/ldap'
      $db_backend          = 'hdb'
      $group               = 'ldap'
      $ldap_conf_file      = "${conf_dir}/ldap.conf"
      $overlay_packages    = {}
      $pid_file            = '/var/run/openldap/slapd.pid'
      $schema_dir          = "${conf_dir}/schema"
      $server_package_name = 'openldap-servers'
      $server_service_name = 'slapd'
      $user                = 'ldap'
    }
    'Debian': {
      $args_file           = '/var/run/slapd/slapd.args'
      $backend_modules     = [
        'bdb',
        'dnssrv',
        'hdb',
        'ldap',
        'mdb',
        'meta',
        'monitor',
        'null',
        'passwd',
        'perl',
        'relay',
        'shell',
        'sock',
        'sql',
      ]
      $backend_packages    = {}
      $base_package_name   = 'libldap-2.4-2'
      $client_package_name = 'ldap-utils'
      $conf_dir            = '/etc/ldap'
      $data_directory      = '/var/lib/ldap'
      $db_backend          = 'hdb'
      $group               = 'openldap'
      $ldap_conf_file      = "${conf_dir}/ldap.conf"
      $overlay_packages    = {
        'smbk5pwd' => 'slapd-smbk5pwd',
      }
      $pid_file            = '/var/run/slapd/slapd.pid'
      $schema_dir          = "${conf_dir}/schema"
      $server_package_name = 'slapd'
      $server_service_name = 'slapd'
      $user                = 'openldap'
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }
}
