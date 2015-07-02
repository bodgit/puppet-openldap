#
class openldap::params {

  $auditlog_file       = ''
  $ldap_interfaces     = ['']
  $ldaps_interfaces    = []
  $module_extension    = '.la'
  $ssl_ca              = undef
  $ssl_cert            = undef
  $ssl_certs_dir       = undef
  $ssl_cipher          = undef
  $ssl_dhparam         = undef
  $ssl_key             = undef
  $ssl_protocol        = undef
  $syncprov_checkpoint = '100 10'
  $syncprov_sessionlog = 100

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
        'sock'
      ]
      $base_package_name   = 'openldap'
      $conf_dir            = '/etc/openldap'
      $ldap_conf_file      = "${conf_dir}/ldap.conf"
      $client_package_name = 'openldap-clients'
      $data_directory      = '/var/lib/ldap'
      $db_backend          = 'hdb'
      $group               = 'ldap'
      $pid_file            = '/var/run/openldap/slapd.pid'
      $schema_dir          = "${conf_dir}/schema"
      $server_package_name = 'openldap-servers'
      $server_service_name = 'slapd'
      $overlay_packages    = {
        'smbk5pwd' => $server_package_name,
      }
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
        'sql'
      ]
      $base_package_name   = 'libldap-2.4-2'
      $conf_dir            = '/etc/ldap'
      $ldap_conf_file      = "${conf_dir}/ldap.conf"
      $client_package_name = 'ldap-utils'
      $data_directory      = '/var/lib/ldap'
      $db_backend          = 'hdb'
      $group               = 'openldap'
      $pid_file            = '/var/run/slapd/slapd.pid'
      $schema_dir          = "${conf_dir}/schema"
      $server_package_name = 'slapd'
      $server_service_name = 'slapd'
      $overlay_packages    = {
        'smbk5pwd' => 'slapd-smbk5pwd',
      }
      $user                = 'openldap'
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.") # lint:ignore:80chars
    }
  }
}
