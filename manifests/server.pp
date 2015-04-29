#
class openldap::server (
  $root_dn,
  $root_password,
  $suffix,
  $access              = [
    'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage', # lint:ignore:80chars
  ],
  $accesslog           = false,
  $args_file           = $::openldap::params::args_file,
  $backend_modules     = $::openldap::params::backend_modules,
  $data_directory      = $::openldap::params::data_directory,
  $db_backend          = $::openldap::params::db_backend,
  #$db_config           = $::openldap::params::db_config,
  $group               = $::openldap::params::group,
  $indices             = undef,
  $ldap_interfaces     = $::openldap::params::ldap_interfaces,
  $ldaps_interfaces    = $::openldap::params::ldaps_interfaces,
  $limits              = [],
  $module_extension    = $::openldap::params::module_extension,
  $package_name        = $::openldap::params::server_package_name,
  $pid_file            = $::openldap::params::pid_file,
  $replica_dn          = undef,
  $schema_dir          = $::openldap::params::schema_dir,
  $ssl_ca              = $::openldap::params::ssl_ca,
  $ssl_cert            = $::openldap::params::ssl_cert,
  $ssl_certs_dir       = $::openldap::params::ssl_certs_dir,
  $ssl_cipher          = $::openldap::params::ssl_cipher,
  $ssl_dhparam         = $::openldap::params::ssl_dhparam,
  $ssl_key             = $::openldap::params::ssl_key,
  $ssl_protocol        = $::openldap::params::ssl_protocol,
  $syncprov            = false,
  $syncprov_checkpoint = $::openldap::params::syncprov_checkpoint,
  $syncprov_sessionlog = $::openldap::params::syncprov_sessionlog,
  $syncrepl            = undef,
  $update_ref          = undef,
  $user                = $::openldap::params::user,
) inherits ::openldap::params {

  if ! defined(Class['::openldap::client']) {
    fail('You must include the openldap::client class before using the openldap::server class') # lint:ignore:80chars
  }

  validate_string($root_dn)
  validate_string($root_password)
  validate_string($suffix)

  validate_array($access)
  validate_bool($accesslog)
  validate_absolute_path($args_file)
  validate_array($backend_modules)
  validate_absolute_path($data_directory)
  validate_string($db_backend)
  validate_string($group)
  if $indices {
    validate_array($indices)
  }
  validate_array($ldap_interfaces)
  validate_array($ldaps_interfaces)
  if $limits {
    validate_array($limits)
  }
  validate_string($package_name)
  validate_absolute_path($pid_file)
  validate_absolute_path($schema_dir)
  if $ssl_ca {
    validate_absolute_path($ssl_ca)
  }
  if $ssl_cert {
    validate_absolute_path($ssl_cert)
  }
  if $ssl_certs_dir {
    validate_absolute_path($ssl_certs_dir)
  }
  if $ssl_cipher {
    validate_string($ssl_cipher)
  }
  if $ssl_dhparam {
    validate_absolute_path($ssl_dhparam)
  }
  if $ssl_key {
    validate_absolute_path($ssl_key)
  }
  if $ssl_protocol {
    validate_number($ssl_protocol)
  }
  validate_bool($syncprov)
  if $syncprov {
    validate_string($replica_dn)
    validate_re($syncprov_checkpoint, '^\d+\s+\d+$')
    validate_integer($syncprov_sessionlog)
  }
  if $syncrepl {
    validate_array($syncrepl)
  }
  if $update_ref {
    validate_array($update_ref)
  }
  validate_string($user)

  include ::openldap::server::install
  include ::openldap::server::config
  include ::openldap::server::service

  anchor { 'openldap::server::begin': }
  anchor { 'openldap::server::end': }

  Anchor['openldap::server::begin'] -> Class['::openldap::server::install']
    -> Class['::openldap::server::service'] -> Anchor['openldap::server::end']

  Class['::openldap::server::install'] -> Class['::openldap::server::config']
    -> Anchor['openldap::server::end']
}
