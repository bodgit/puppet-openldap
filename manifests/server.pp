#
class openldap::server (
  $root_dn,
  $root_password,
  $suffix,
  $access                    = [
    'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage', # lint:ignore:80chars
  ],
  $accesslog                 = false,
  $accesslog_cachesize       = undef,
  $accesslog_checkpoint      = undef,
  $accesslog_db_config       = [],
  $accesslog_dn_cachesize    = undef,
  $accesslog_index_cachesize = undef,
  $args_file                 = $::openldap::params::args_file,
  $auditlog                  = false,
  $auditlog_file             = $::openldap::params::auditlog_file,
  $backend_modules           = $::openldap::params::backend_modules,
  $data_cachesize            = undef,
  $data_checkpoint           = undef,
  $data_db_config            = [],
  $data_directory            = $::openldap::params::data_directory,
  $data_dn_cachesize         = undef,
  $data_index_cachesize      = undef,
  $db_backend                = $::openldap::params::db_backend,
  $group                     = $::openldap::params::group,
  $indices                   = undef,
  $ldap_interfaces           = $::openldap::params::ldap_interfaces,
  $ldaps_interfaces          = $::openldap::params::ldaps_interfaces,
  $limits                    = [],
  $local_ssf                 = undef,
  $module_extension          = $::openldap::params::module_extension,
  $package_name              = $::openldap::params::server_package_name,
  $pid_file                  = $::openldap::params::pid_file,
  $replica_dn                = undef,
  $schema_dir                = $::openldap::params::schema_dir,
  $security                  = undef,
  $ssl_ca                    = $::openldap::params::ssl_ca,
  $ssl_cert                  = $::openldap::params::ssl_cert,
  $ssl_certs_dir             = $::openldap::params::ssl_certs_dir,
  $ssl_cipher                = $::openldap::params::ssl_cipher,
  $ssl_dhparam               = $::openldap::params::ssl_dhparam,
  $ssl_key                   = $::openldap::params::ssl_key,
  $ssl_protocol              = $::openldap::params::ssl_protocol,
  $syncprov                  = false,
  $syncprov_checkpoint       = $::openldap::params::syncprov_checkpoint,
  $syncprov_sessionlog       = $::openldap::params::syncprov_sessionlog,
  $syncrepl                  = undef,
  $update_ref                = undef,
  $user                      = $::openldap::params::user,
) inherits ::openldap::params {

  if ! defined(Class['::openldap::client']) {
    fail('You must include the openldap::client class before using the openldap::server class') # lint:ignore:80chars
  }

  validate_string($root_dn)
  validate_string($root_password)
  validate_string($suffix)

  validate_array($access)
  validate_bool($accesslog)
  if $accesslog_cachesize {
    validate_integer($accesslog_cachesize)
  }
  if $accesslog_checkpoint {
    validate_re($accesslog_checkpoint, '^\d+\s+\d+$')
  }
  validate_array($accesslog_db_config)
  if $accesslog_dn_cachesize {
    validate_integer($accesslog_dn_cachesize)
  }
  if $accesslog_index_cachesize {
    validate_integer($accesslog_index_cachesize)
  }
  validate_bool($auditlog)
  if $auditlog {
    validate_absolute_path($auditlog_file)
  }
  validate_absolute_path($args_file)
  validate_array($backend_modules)
  if $data_cachesize {
    validate_integer($data_cachesize)
  }
  if $data_checkpoint {
    validate_re($data_checkpoint, '^\d+\s+\d+$')
  }
  validate_array($data_db_config)
  validate_absolute_path($data_directory)
  if $data_dn_cachesize {
    validate_integer($data_dn_cachesize)
  }
  if $data_index_cachesize {
    validate_integer($data_index_cachesize)
  }
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
  if $local_ssf {
    validate_integer($local_ssf)
  }
  validate_string($package_name)
  validate_absolute_path($pid_file)
  validate_absolute_path($schema_dir)
  if $security {
    validate_re($security, '^\w+=\d+(?:\s+\w+=\d+)*$')
  }
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
