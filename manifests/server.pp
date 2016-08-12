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
  $authz_policy              = undef,
  $backend_modules           = $::openldap::params::backend_modules,
  $chain                     = false,
  $chain_id_assert_bind      = undef,
  $chain_rebind_as_user      = undef,
  $chain_return_error        = undef,
  $data_cachesize            = undef,
  $data_checkpoint           = undef,
  $data_db_config            = [],
  $data_directory            = $::openldap::params::data_directory,
  $data_dn_cachesize         = undef,
  $data_index_cachesize      = undef,
  $db_backend                = $::openldap::params::db_backend,
  $group                     = $::openldap::params::group,
  $indices                   = [],
  $ldap_interfaces           = $::openldap::params::ldap_interfaces,
  $ldaps_interfaces          = $::openldap::params::ldaps_interfaces,
  $limits                    = [],
  $local_ssf                 = $::openldap::params::local_ssf,
  $log_level                 = $::openldap::params::log_level,
  $module_extension          = $::openldap::params::module_extension,
  $package_name              = $::openldap::params::server_package_name,
  $pid_file                  = $::openldap::params::pid_file,
  $ppolicy                   = false,
  $ppolicy_default           = undef,
  $ppolicy_forward_updates   = undef,
  $ppolicy_hash_cleartext    = undef,
  $ppolicy_use_lockout       = undef,
  $replica_dn                = undef,
  $schema_dir                = $::openldap::params::schema_dir,
  $security                  = undef,
  $size_limit                = undef,
  $smbk5pwd                  = false,
  $smbk5pwd_backends         = [],
  $smbk5pwd_must_change      = undef,
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
  $time_limit                = undef,
  $unique                    = false,
  $unique_uri                = $::openldap::params::unique_uri,
  $update_ref                = undef,
  $user                      = $::openldap::params::user,
) inherits ::openldap::params {

  if ! defined(Class['::openldap::client']) {
    fail('You must include the openldap::client class before using the openldap::server class') # lint:ignore:80chars
  }

  validate_string($root_dn)
  validate_ldap_dn($root_dn)
  validate_string($root_password)
  validate_string($suffix)
  validate_ldap_dn($suffix)

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
  validate_absolute_path($args_file)
  validate_bool($auditlog)
  if $auditlog {
    validate_absolute_path($auditlog_file)
  }
  if $authz_policy {
    validate_re($authz_policy, '^(?:none|from|to|any|all)$')
  }
  validate_array($backend_modules)
  if $chain {
    validate_bool($chain)
    validate_string($chain_id_assert_bind)
    if $chain_rebind_as_user {
      validate_bool($chain_rebind_as_user)
    }
    if $chain_return_error {
      validate_bool($chain_return_error)
    }
  }
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
  validate_array($indices)
  validate_array($ldap_interfaces)
  validate_array($ldaps_interfaces)
  if $limits {
    validate_array($limits)
  }
  if $local_ssf {
    validate_integer($local_ssf)
  }
  if $log_level {
    validate_re($log_level, '^(?:\d+|0x\h+|\w+)(?:\s+(?:\d+|0x\h+|\w+))*$')
  }
  validate_string($package_name)
  validate_absolute_path($pid_file)
  if $ppolicy {
    if $ppolicy_default {
      validate_string($ppolicy_default)
      validate_ldap_sub_dn($suffix, $ppolicy_default)
    }
    if $ppolicy_forward_updates {
      validate_bool($ppolicy_forward_updates)
    }
    if $ppolicy_hash_cleartext {
      validate_bool($ppolicy_hash_cleartext)
    }
    if $ppolicy_use_lockout {
      validate_bool($ppolicy_use_lockout)
    }
  }
  validate_absolute_path($schema_dir)
  if $security {
    validate_re($security, '^\w+=\d+(?:\s+\w+=\d+)*$')
  }
  if $size_limit {
    validate_re("${size_limit}", '^(?:(size)(?:\.\w+)?=)?(?:\d+|unlimited)(?:\s+\1(?:\.\w+)?=(?:\d+|unlimited))*$') # lint:ignore:80chars lint:ignore:only_variable_string
  }
  validate_bool($smbk5pwd)
  if $smbk5pwd {
    validate_array($smbk5pwd_backends)
    if $smbk5pwd_must_change {
      validate_integer($smbk5pwd_must_change)
    }
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
    validate_numeric($ssl_protocol, '', 0)
  }
  validate_bool($syncprov)
  if $syncprov {
    validate_string($replica_dn)
    validate_ldap_dn($replica_dn)
    validate_re($syncprov_checkpoint, '^\d+\s+\d+$')
    validate_integer($syncprov_sessionlog)
  }
  if $syncrepl {
    validate_array($syncrepl)
  }
  if $time_limit {
    validate_re("${time_limit}", '^(?:(time)(?:\.\w+)?=)?(?:\d+|unlimited)(?:\s+\1(?:\.\w+)?=(?:\d+|unlimited))*$') # lint:ignore:80chars lint:ignore:only_variable_string
  }
  validate_bool($unique)
  if $unique {
    if $unique_uri {
      validate_array($unique_uri)
      validate_openldap_unique_uri($suffix, $unique_uri)
    }
  }
  if $update_ref {
    validate_string($update_ref)
    validate_ldap_uri($update_ref)
  }
  validate_string($user)

  if $chain and ! $update_ref {
    fail('Chaining requires an update referral URL')
  }

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
