# @!visibility private
class openldap::server::config {

  $backend_modules  = $::openldap::server::backend_modules
  $data_directory   = $::openldap::server::data_directory
  $db_backend       = $::openldap::server::db_backend
  $group            = $::openldap::server::group
  $interfaces       = $::openldap::server::interfaces
  $module_extension = $::openldap::server::module_extension
  $password_hash    = $::openldap::server::password_hash
  $replica_dn       = $::openldap::server::replica_dn
  $user             = $::openldap::server::user

  file { $data_directory:
    ensure       => directory,
    owner        => $user,
    group        => $group,
    mode         => '0600',
    purge        => true,
    recurse      => true,
    recurselimit => 1,
  }

  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '6': {
          $sysconfig = '/etc/sysconfig/ldap'
        }
        default: {
          $sysconfig = '/etc/sysconfig/slapd'
        }
      }
      file { $sysconfig:
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0644',
        content => template("${module_name}/sysconfig.erb"),
        notify  => Class['::openldap::server::service'],
      }
    }
    'Debian': {
      file { '/etc/default/slapd':
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0644',
        content => template("${module_name}/default.erb"),
        notify  => Class['::openldap::server::service'],
      }
    }
    default: {
      # noop
    }
  }

  openldap { 'cn=config':
    ensure     => present,
    attributes => delete_undef_values({
      'cn'                         => 'config',
      'objectClass'                => 'olcGlobal',
      'olcArgsFile'                => $::openldap::server::args_file,
      'olcAuthzPolicy'             => $::openldap::server::authz_policy,
      'olcLocalSSF'                => $::openldap::server::local_ssf,
      'olcLogLevel'                => openldap::flatten_generic($::openldap::server::log_level),
      'olcPidFile'                 => $::openldap::server::pid_file,
      'olcSecurity'                => openldap::flatten_security($::openldap::server::security),
      'olcTLSCACertificateFile'    => $::openldap::server::ssl_ca,
      'olcTLSCACertificatePath'    => $::openldap::server::ssl_certs_dir,
      'olcTLSCertificateFile'      => $::openldap::server::ssl_cert,
      'olcTLSCertificateKeyFile'   => $::openldap::server::ssl_key,
      'olcTLSCipherSuite'          => $::openldap::server::ssl_cipher,
      'olcTLSDHParamFile'          => $::openldap::server::ssl_dhparam,
      'olcTLSProtocolMin'          => $::openldap::server::ssl_protocol,
      'olcPasswordCryptSaltFormat' => $::openldap::server::password_crypt_salt_format,
    }),
  }

  $overlays = delete_undef_values([
    $::openldap::server::syncprov ? {
      true    => 'syncprov',
      default => undef,
    },
    $::openldap::server::accesslog ? {
      true    => 'accesslog',
      default => undef,
    },
    $::openldap::server::auditlog ? {
      true    => 'auditlog',
      default => undef,
    },
    $::openldap::server::smbk5pwd ? {
      true    => 'smbk5pwd',
      default => undef,
    },
    $::openldap::server::unique ? {
      true    => 'unique',
      default => undef,
    },
    $::openldap::server::ppolicy ? {
      true    => 'ppolicy',
      default => undef,
    },
    $::openldap::server::memberof ? {
      true    => 'memberof',
      default => undef,
    },
  ])

  # Creates a hash based on the enabled overlays pointing to their intended
  # position on the database. So for example if only the 'syncprov' and
  # 'smbk5pwd' overlays are enabled it results in the following:
  #
  # {
  #   syncprov  => '{0}syncprov',
  #   smbk5pwd  => '{1}smbk5pwd',
  # }
  $overlay_index = hash(flatten(zip($overlays, openldap::values($overlays))))

  $overlay_modules = $overlays.filter |String $x| { member($::openldap::server::overlay_modules, $x) }
  $overlay_packages = unique(delete_undef_values($overlay_modules.map |String $x| { $::openldap::server::overlay_packages[$x] }))

  if $password_hash {
    # Generate a unique list of modules needed to satisfy the chosen password
    # hashes and subsequently a unique list of packages needed to be installed
    $password_modules  = unique(delete_undef_values($password_hash.map |String $x| { $::openldap::server::password_modules[$x] }))
    $password_packages = unique(delete_undef_values($password_modules.map |String $x| { $::openldap::server::password_packages[$x] }))
  } else {
    $password_modules  = []
    $password_packages = []
  }

  $modules = flatten([delete_undef_values([
    member($backend_modules, 'monitor') ? {
      true    => 'back_monitor',
      default => undef,
    },
    member($backend_modules, $db_backend) ? {
      true    => "back_${db_backend}",
      default => undef,
    },
    # If chaining is enabled then the ldap backend is required
    $::openldap::server::chain ? {
      true    => member($backend_modules, 'ldap') ? {
        true    => 'back_ldap',
        default => undef,
      },
      default => undef,
    },
  ]), $overlay_modules, $password_modules])

  # Convert ['module1', 'module2'] into ['{0}module1.la', '{1}module2.la']
  $module_load = suffix(openldap::values($modules), $module_extension)

  # Either no modules to load or dynamic modules aren't supported
  if size($modules) > 0 {
    openldap { 'cn=module{0},cn=config':
      ensure     => present,
      attributes => {
        'cn'            => 'module{0}',
        'objectClass'   => 'olcModuleList',
        'olcModuleLoad' => $module_load,
      },
    }
  }

  if size($password_packages) > 0 {
    package { $password_packages:
      ensure => present,
      before => Openldap['cn=module{0},cn=config'],
    }
  }

  if size($overlay_packages) > 0 {
    package { $overlay_packages:
      ensure => present,
      before => Openldap['cn=module{0},cn=config'],
    }
  }

  openldap { 'cn=schema,cn=config':
    ensure     => present,
    attributes => {
      'cn'          => 'schema',
      'objectClass' => 'olcSchemaConfig',
    },
  }

  openldap_schema { 'core':
    ensure => present,
    ldif   => "${::openldap::server::schema_dir}/core.ldif",
  }

  openldap { 'olcDatabase={-1}frontend,cn=config':
    ensure     => present,
    attributes => delete_undef_values({
      'objectClass'     => [
        'olcDatabaseConfig',
        'olcFrontendConfig',
      ],
      'olcDatabase'     => '{-1}frontend',
      'olcSizeLimit'    => openldap::flatten_size_limit($::openldap::server::size_limit),
      'olcTimeLimit'    => openldap::flatten_time_limit($::openldap::server::time_limit),
      'olcPasswordHash' => openldap::flatten_generic($password_hash),
    }),
  }

  if $::openldap::server::chain {
    openldap { 'olcOverlay={0}chain,olcDatabase={-1}frontend,cn=config':
      ensure     => present,
      attributes => delete_undef_values({
        'objectClass'         => [
          'olcOverlayConfig',
          'olcChainConfig',
        ],
        'olcOverlay'          => '{0}chain',
        'olcChainReturnError' => openldap::boolean($::openldap::server::chain_return_error),
      }),
    }

    if size($modules) > 0 {
      Openldap['cn=module{0},cn=config'] -> Openldap['olcOverlay={0}chain,olcDatabase={-1}frontend,cn=config']
    }

    $::openldap::server::update_ref.each |Integer $i, Bodgitlib::LDAP::URI::Simple $uri| {

      openldap { "olcDatabase={${i}}ldap,olcOverlay={0}chain,olcDatabase={-1}frontend,cn=config":
        ensure     => present,
        attributes => delete_undef_values({
          'objectClass'       => [
            'olcLDAPConfig',
            'olcChainDatabase',
          ],
          'olcDatabase'       => "{${i}}ldap",
          'olcDbURI'          => $uri,
          'olcDbRebindAsUser' => openldap::boolean($::openldap::server::chain_rebind_as_user),
          'olcDbIDAssertBind' => openldap::flatten_ldap_id_assert_bind($::openldap::server::chain_id_assert_bind),
          'olcDbStartTLS'     => openldap::flatten_ldap_tls($::openldap::server::chain_tls),
        }),
      }
    }
  }

  openldap { 'olcDatabase={0}config,cn=config':
    ensure     => present,
    attributes => {
      'objectClass' => 'olcDatabaseConfig',
      'olcAccess'   => '{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by * none',
      'olcDatabase' => '{0}config',
      'olcLimits'   => '{0}dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited', # lint:ignore:140chars
    },
  }

  openldap { 'olcDatabase={1}monitor,cn=config':
    ensure     => present,
    attributes => {
      'objectClass' => 'olcDatabaseConfig',
      'olcAccess'   => '{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by * none',
      'olcDatabase' => '{1}monitor',
    },
  }

  if size($modules) > 0 {
    Openldap['cn=module{0},cn=config'] -> Openldap['olcDatabase={1}monitor,cn=config']
  }

  # Assume foo backend uses olcFooConfig class, works for *db at least
  $object_class = sprintf('olc%sConfig', capitalize($db_backend))

  $syncprov_indices = [[['entryCSN', 'entryUUID'], ['eq']]]

  # syncprov overlay is required, i.e. this is a master/producer
  if $::openldap::server::syncprov {

    $replica_access = $replica_dn.map |String $x| {
      "to * by dn.exact=\"${x}\" read"
    }

    $replica_limits = $replica_dn.map |String $x| {
      {
        'selector' => "dn.exact=\"${x}\"",
        'time'     => {
          'soft' => 'unlimited',
          'hard' => 'unlimited',
        },
        'size'     => {
          'soft' => 'unlimited',
          'hard' => 'unlimited',
        },
      }
    }

    # Prepend replica ACL to any on the main database and also create indices
    # required by the overlay
    $access = $replica_access.map |String $x| {
      "${x} by * break"
    } + $::openldap::server::access

    if $::openldap::server::indices {
      $indices = $::openldap::server::indices + $syncprov_indices
    } else {
      $indices = $syncprov_indices
    }

    if $::openldap::server::limits {
      $limits = $replica_limits + $::openldap::server::limits
    } else {
      $limits = $replica_limits
    }

    # accesslog overlay is required, i.e. delta-syncrepl
    if $::openldap::server::accesslog {

      file { "${data_directory}/log":
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => '0600',
      }

      openldap { "olcDatabase={2}${db_backend},cn=config":
        ensure     => present,
        attributes => delete_undef_values({
          'objectClass'       => [
            'olcDatabaseConfig',
            $object_class,
          ],
          'olcAccess'         => openldap::values($replica_access),
          'olcDatabase'       => "{2}${db_backend}",
          'olcDbCacheSize'    => $::openldap::server::accesslog_cachesize,
          'olcDbCheckpoint'   => openldap::flatten_checkpoint($::openldap::server::accesslog_checkpoint),
          'olcDbConfig'       => openldap::values($::openldap::server::accesslog_db_config),
          'olcDbDirectory'    => "${data_directory}/log",
          'olcDbDNcacheSize'  => $::openldap::server::accesslog_dn_cachesize,
          'olcDbIDLcacheSize' => $::openldap::server::accesslog_index_cachesize,
          'olcDbIndex'        => [
            'entryCSN,objectClass,reqEnd,reqResult,reqStart eq',
          ],
          'olcLimits'         => openldap::values(openldap::flatten_limits($replica_limits)),
          'olcRootDN'         => $::openldap::server::root_dn,
          'olcSuffix'         => 'cn=log',
        }),
      }

      openldap { "olcOverlay={0}syncprov,olcDatabase={2}${db_backend},cn=config":
        ensure     => present,
        attributes => delete_undef_values({
          'objectClass'     => [
            'olcOverlayConfig',
            'olcSyncProvConfig',
          ],
          'olcOverlay'      => '{0}syncprov',
          'olcSpCheckpoint' => openldap::flatten_checkpoint($::openldap::server::syncprov_checkpoint),
          'olcSpNoPresent'  => openldap::boolean(true),
          'olcSpReloadHint' => openldap::boolean(true),
          'olcSpSessionlog' => $::openldap::server::syncprov_sessionlog,
        }),
      }

      if size($modules) > 0 {
        Openldap['cn=module{0},cn=config'] -> Openldap["olcDatabase={2}${db_backend},cn=config"]
        Openldap['cn=module{0},cn=config'] -> Openldap["olcOverlay={0}syncprov,olcDatabase={2}${db_backend},cn=config"]
      }

      # The main database is now shuffled along by one
      $db_index = 3
    } else {
      $db_index = 2
    }
  } else {
    $access = $::openldap::server::access

    # If this is a slave/consumer, create necessary indices
    if $::openldap::server::syncrepl {
      if $::openldap::server::indices {
        $indices = $::openldap::server::indices + $syncprov_indices
      } else {
        $indices = $syncprov_indices
      }
    } else {
      $indices = $::openldap::server::indices
    }

    $limits = $::openldap::server::limits

    $db_index = 2
  }

  file { "${data_directory}/data":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0600',
  }

  openldap { "olcDatabase={${db_index}}${db_backend},cn=config":
    ensure     => present,
    attributes => delete_undef_values({
      'objectClass'       => [
        'olcDatabaseConfig',
        $object_class,
      ],
      'olcAccess'         => openldap::values($access),
      'olcDatabase'       => "{${db_index}}${db_backend}",
      'olcDbCacheSize'    => $::openldap::server::data_cachesize,
      'olcDbCheckpoint'   => openldap::flatten_checkpoint($::openldap::server::data_checkpoint),
      'olcDbConfig'       => openldap::values($::openldap::server::data_db_config),
      'olcDbDirectory'    => "${data_directory}/data",
      'olcDbDNcacheSize'  => $::openldap::server::data_dn_cachesize,
      'olcDbIDLcacheSize' => $::openldap::server::data_index_cachesize,
      'olcDbIndex'        => openldap::flatten_indices($indices),
      'olcLimits'         => openldap::values(openldap::flatten_limits($limits)),
      'olcRootDN'         => $::openldap::server::root_dn,
      'olcRootPW'         => $::openldap::server::root_password,
      'olcSuffix'         => $::openldap::server::suffix,
      # slave/consumer
      'olcSyncrepl'       => openldap::values(openldap::flatten_syncrepl($::openldap::server::syncrepl)),
      'olcUpdateRef'      => $::openldap::server::update_ref,
    }),
  }

  if size($modules) > 0 {
    Openldap['cn=module{0},cn=config'] -> Openldap["olcDatabase={${db_index}}${db_backend},cn=config"]
  }

  if $::openldap::server::syncprov {
    openldap { "olcOverlay=${overlay_index['syncprov']},olcDatabase={${db_index}}${db_backend},cn=config":
      ensure     => present,
      attributes => delete_undef_values({
        'objectClass'     => [
          'olcOverlayConfig',
          'olcSyncProvConfig',
        ],
        'olcOverlay'      => $overlay_index['syncprov'],
        'olcSpCheckpoint' => openldap::flatten_checkpoint($::openldap::server::syncprov_checkpoint),
        'olcSpReloadHint' => openldap::boolean(true),
        'olcSpSessionlog' => $::openldap::server::syncprov_sessionlog,
      }),
    }

    if size($modules) > 0 {
      Openldap['cn=module{0},cn=config'] -> Openldap["olcOverlay=${overlay_index['syncprov']},olcDatabase={${db_index}}${db_backend},cn=config"]
    }

    if $::openldap::server::accesslog {
      openldap { "olcOverlay=${overlay_index['accesslog']},olcDatabase={${db_index}}${db_backend},cn=config":
        ensure     => present,
        attributes => delete_undef_values({
          'objectClass'         => [
            'olcOverlayConfig',
            'olcAccessLogConfig',
          ],
          'olcOverlay'          => $overlay_index['accesslog'],
          'olcAccessLogDB'      => 'cn=log',
          'olcAccessLogOps'     => 'writes',
          'olcAccessLogSuccess' => openldap::boolean(true),
          'olcAccessLogPurge'   => '07+00:00 01+00:00',
        }),
      }

      if size($modules) > 0 {
        Openldap['cn=module{0},cn=config'] -> Openldap["olcOverlay=${overlay_index['accesslog']},olcDatabase={${db_index}}${db_backend},cn=config"]
      }
    }
  }

  if $::openldap::server::auditlog {
    openldap { "olcOverlay=${overlay_index['auditlog']},olcDatabase={${db_index}}${db_backend},cn=config":
      ensure     => present,
      attributes => delete_undef_values({
        'objectClass'     => [
          'olcOverlayConfig',
          'olcAuditlogConfig',
        ],
        'olcOverlay'      => $overlay_index['auditlog'],
        'olcAuditlogFile' => $::openldap::server::auditlog_file,
      }),
    }

    if size($modules) > 0 {
      Openldap['cn=module{0},cn=config'] -> Openldap["olcOverlay=${overlay_index['auditlog']},olcDatabase={${db_index}}${db_backend},cn=config"]
    }
  }

  if $::openldap::server::smbk5pwd {
    openldap { "olcOverlay=${overlay_index['smbk5pwd']},olcDatabase={${db_index}}${db_backend},cn=config":
      ensure     => present,
      attributes => delete_undef_values({
        'objectClass'           => [
          'olcOverlayConfig',
          'olcSmbK5PwdConfig',
        ],
        'olcOverlay'            => $overlay_index['smbk5pwd'],
        'olcSmbK5PwdEnable'     => $::openldap::server::smbk5pwd_backends,
        'olcSmbK5PwdMustChange' => $::openldap::server::smbk5pwd_must_change,
      }),
    }

    if size($modules) > 0 {
      Openldap['cn=module{0},cn=config'] -> Openldap["olcOverlay=${overlay_index['smbk5pwd']},olcDatabase={${db_index}}${db_backend},cn=config"]
    }
  }

  if $::openldap::server::unique {
    openldap { "olcOverlay=${overlay_index['unique']},olcDatabase={${db_index}}${db_backend},cn=config":
      ensure     => present,
      attributes => delete_undef_values({
        'objectClass'  => [
          'olcOverlayConfig',
          'olcUniqueConfig',
        ],
        'olcOverlay'   => $overlay_index['unique'],
        'olcUniqueURI' => openldap::flatten_unique($::openldap::server::unique_uri),
      }),
    }

    if size($modules) > 0 {
      Openldap['cn=module{0},cn=config'] -> Openldap["olcOverlay=${overlay_index['unique']},olcDatabase={${db_index}}${db_backend},cn=config"]
    }
  }

  if $::openldap::server::ppolicy {
    openldap_schema { 'ppolicy':
      ensure => present,
      ldif   => "${::openldap::server::schema_dir}/ppolicy.ldif",
    }

    openldap { "olcOverlay=${overlay_index['ppolicy']},olcDatabase={${db_index}}${db_backend},cn=config":
      ensure     => present,
      attributes => delete_undef_values({
        'objectClass'              => [
          'olcOverlayConfig',
          'olcPPolicyConfig',
        ],
        'olcOverlay'               => $overlay_index['ppolicy'],
        'olcPPolicyDefault'        => $::openldap::server::ppolicy_default,
        'olcPPolicyHashCleartext'  => openldap::boolean($::openldap::server::ppolicy_hash_cleartext),
        'olcPPolicyUseLockout'     => openldap::boolean($::openldap::server::ppolicy_use_lockout),
        'olcPPolicyForwardUpdates' => openldap::boolean($::openldap::server::ppolicy_forward_updates),
      }),
    }

    if size($modules) > 0 {
      Openldap['cn=module{0},cn=config'] -> Openldap["olcOverlay=${overlay_index['ppolicy']},olcDatabase={${db_index}}${db_backend},cn=config"]
    }
  }

  if $::openldap::server::memberof {
    openldap { "olcOverlay=${overlay_index['memberof']},olcDatabase={${db_index}}${db_backend},cn=config":
      ensure     => present,
      attributes => delete_undef_values({
        'objectClass' => [
          'olcOverlayConfig',
        ],
        'olcOverlay'  => $overlay_index['memberof'],
      }),
    }

    if size($modules) > 0 {
      Openldap['cn=module{0},cn=config'] -> Openldap["olcOverlay=${overlay_index['memberof']},olcDatabase={${db_index}}${db_backend},cn=config"]
    }
  }
}
