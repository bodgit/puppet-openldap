#
class openldap::server::config {

  $backend_modules  = $::openldap::server::backend_modules
  $data_directory   = $::openldap::server::data_directory
  $db_backend       = $::openldap::server::db_backend
  $group            = $::openldap::server::group
  $module_extension = $::openldap::server::module_extension
  $overlay_packages = $::openldap::server::overlay_packages
  $replica_dn       = $::openldap::server::replica_dn
  $user             = $::openldap::server::user

  # Wrap each 'address:port' with the correct URL scheme and trailing '/'
  $ldap_interfaces = suffix(prefix($::openldap::server::ldap_interfaces, 'ldap://'), '/')
  $ldaps_interfaces = suffix(prefix($::openldap::server::ldaps_interfaces, 'ldaps://'), '/')

  file { $data_directory:
    ensure       => directory,
    owner        => $user,
    group        => $group,
    mode         => '0600',
    purge        => true,
    recurse      => true,
    recurselimit => 1,
    require      => [
      User[$user],
      Group[$group],
    ],
  }

  case $::osfamily { # lint:ignore:case_without_default
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
        content => template('openldap/sysconfig.erb'),
        notify  => Class['::openldap::server::service'],
      }
    }
    'Debian': {
      file { '/etc/default/slapd':
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0644',
        content => template('openldap/default.erb'),
        notify  => Class['::openldap::server::service'],
      }
    }
  }

  openldap { 'cn=config':
    ensure     => present,
    attributes => delete_undef_values({
      'cn'                       => 'config',
      'objectClass'              => 'olcGlobal',
      'olcArgsFile'              => $::openldap::server::args_file,
      'olcAuthzPolicy'           => $::openldap::server::authz_policy,
      'olcLocalSSF'              => $::openldap::server::local_ssf,
      'olcLogLevel'              => $::openldap::server::log_level,
      'olcPidFile'               => $::openldap::server::pid_file,
      'olcSecurity'              => $::openldap::server::security,
      'olcTLSCACertificateFile'  => $::openldap::server::ssl_ca,
      'olcTLSCACertificatePath'  => $::openldap::server::ssl_certs_dir,
      'olcTLSCertificateFile'    => $::openldap::server::ssl_cert,
      'olcTLSCertificateKeyFile' => $::openldap::server::ssl_key,
      'olcTLSCipherSuite'        => $::openldap::server::ssl_cipher,
      'olcTLSDHParamFile'        => $::openldap::server::ssl_dhparam,
      'olcTLSProtocolMin'        => $::openldap::server::ssl_protocol,
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
  ])

  # Creates a hash based on the enabled overlays pointing to their intended
  # position on the database. So for example if only the 'syncprov' and
  # 'smbk5pwd' overlays are enabled it results in the following:
  #
  # {
  #   syncprov  => '{0}syncprov',
  #   smbk5pwd  => '{1}smbk5pwd',
  # }
  $overlay_index = hash(flatten(zip($overlays, openldap_values($overlays))))

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
  ]), $overlays])

  # Convert ['module1', 'module2'] into ['{0}module1.la', '{1}module2.la']
  $module_load = suffix(openldap_values($modules), $module_extension)

  openldap { 'cn=module{0},cn=config':
    ensure     => present,
    attributes => {
      'cn'            => 'module{0}',
      'objectClass'   => 'olcModuleList',
      'olcModuleLoad' => $module_load,
    },
  }

  openldap { 'cn=schema,cn=config':
    ensure     => present,
    attributes => {
      'cn'          => 'schema',
      'objectClass' => 'olcSchemaConfig',
    },
  }

  ::openldap::server::schema { 'core':
    position => 0,
  }

  openldap { 'olcDatabase={-1}frontend,cn=config':
    ensure     => present,
    attributes => delete_undef_values({
      'objectClass'  => [
        'olcDatabaseConfig',
        'olcFrontendConfig',
      ],
      'olcDatabase'  => '{-1}frontend',
      'olcSizeLimit' => $::openldap::server::size_limit,
      'olcTimeLimit' => $::openldap::server::time_limit,
    }),
  }

  if $::openldap::server::chain {
    $_chain_return_error = $::openldap::server::chain_return_error ? {
      undef   => undef,
      default => bool2str($::openldap::server::chain_return_error, 'TRUE', 'FALSE'),
    }

    openldap { 'olcOverlay={0}chain,olcDatabase={-1}frontend,cn=config':
      ensure     => present,
      attributes => delete_undef_values({
        'objectClass'         => [
          'olcOverlayConfig',
          'olcChainConfig',
        ],
        'olcOverlay'          => '{0}chain',
        'olcChainReturnError' => $_chain_return_error,
      }),
      require    => Openldap['cn=module{0},cn=config'],
    }

    $_chain_rebind_as_user = $::openldap::server::chain_rebind_as_user ? {
      undef   => undef,
      default => bool2str($::openldap::server::chain_rebind_as_user, 'TRUE', 'FALSE'),
    }

    openldap { 'olcDatabase={0}ldap,olcOverlay={0}chain,olcDatabase={-1}frontend,cn=config':
      ensure     => present,
      attributes => delete_undef_values({
        'objectClass'       => [
          'olcLDAPConfig',
          'olcChainDatabase',
        ],
        'olcDatabase'       => '{0}ldap',
        'olcDbURI'          => $::openldap::server::update_ref,
        'olcDbRebindAsUser' => $_chain_rebind_as_user,
        'olcDbIDAssertBind' => $::openldap::server::chain_id_assert_bind,
        'olcDbStartTLS'     => $::openldap::server::chain_tls,
      }),
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
    require    => Openldap['cn=module{0},cn=config'],
  }

  # Assume foo backend uses olcFooConfig class, works for *db at least
  $object_class = sprintf('olc%sConfig', capitalize($db_backend))

  # syncprov overlay is required, i.e. this is a master/producer
  if $::openldap::server::syncprov {

    $replica_access = "to * by dn.exact=\"${replica_dn}\" read"
    $replica_limits = "dn.exact=\"${replica_dn}\" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited" # lint:ignore:140chars

    # Prepend replica ACL to any on the main database and also create indices
    # required by the overlay
    $access  = flatten(["${replica_access} by * break",
      $::openldap::server::access])
    $indices = openldap_unique_indices(
      flatten([$::openldap::server::indices, 'entryCSN,entryUUID eq'])
    )
    $limits  = flatten([$replica_limits, $::openldap::server::limits])

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
          'olcAccess'         => openldap_values($replica_access),
          'olcDatabase'       => "{2}${db_backend}",
          'olcDbCacheSize'    => $::openldap::server::accesslog_cachesize,
          'olcDbCheckpoint'   => $::openldap::server::accesslog_checkpoint,
          'olcDbConfig'       => openldap_values($::openldap::server::accesslog_db_config),
          'olcDbDirectory'    => "${data_directory}/log",
          'olcDbDNcacheSize'  => $::openldap::server::accesslog_dn_cachesize,
          'olcDbIDLcacheSize' => $::openldap::server::accesslog_index_cachesize,
          'olcDbIndex'        => [
            'entryCSN eq',
            'objectClass eq',
            'reqEnd eq',
            'reqResult eq',
            'reqStart eq',
          ],
          'olcLimits'         => openldap_values($replica_limits),
          'olcRootDN'         => $::openldap::server::root_dn,
          'olcSuffix'         => 'cn=log',
        }),
        require    => Openldap['cn=module{0},cn=config'],
      }

      openldap { "olcOverlay={0}syncprov,olcDatabase={2}${db_backend},cn=config":
        ensure     => present,
        attributes => delete_undef_values({
          'objectClass'     => [
            'olcOverlayConfig',
            'olcSyncProvConfig',
          ],
          'olcOverlay'      => '{0}syncprov',
          'olcSpCheckpoint' => $::openldap::server::syncprov_checkpoint,
          'olcSpNoPresent'  => 'TRUE',
          'olcSpReloadHint' => 'TRUE',
          'olcSpSessionlog' => $::openldap::server::syncprov_sessionlog,
        }),
        require    => Openldap['cn=module{0},cn=config'],
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
      $indices = openldap_unique_indices(
        flatten([$::openldap::server::indices, 'entryCSN,entryUUID eq'])
      )
    } else {
      $indices = openldap_unique_indices($::openldap::server::indices)
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
      'olcAccess'         => openldap_values($access),
      'olcDatabase'       => "{${db_index}}${db_backend}",
      'olcDbCacheSize'    => $::openldap::server::data_cachesize,
      'olcDbCheckpoint'   => $::openldap::server::data_checkpoint,
      'olcDbConfig'       => openldap_values($::openldap::server::data_db_config),
      'olcDbDirectory'    => "${data_directory}/data",
      'olcDbDNcacheSize'  => $::openldap::server::data_dn_cachesize,
      'olcDbIDLcacheSize' => $::openldap::server::data_index_cachesize,
      'olcDbIndex'        => $indices,
      'olcLimits'         => openldap_values($limits),
      'olcRootDN'         => $::openldap::server::root_dn,
      'olcRootPW'         => $::openldap::server::root_password,
      'olcSuffix'         => $::openldap::server::suffix,
      # slave/consumer
      'olcSyncrepl'       => openldap_values($::openldap::server::syncrepl),
      'olcUpdateRef'      => $::openldap::server::update_ref,
    }),
    require    => Openldap['cn=module{0},cn=config'],
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
        'olcSpCheckpoint' => $::openldap::server::syncprov_checkpoint,
        'olcSpReloadHint' => 'TRUE',
        'olcSpSessionlog' => $::openldap::server::syncprov_sessionlog,
      }),
      require    => Openldap['cn=module{0},cn=config'],
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
          'olcAccessLogSuccess' => 'TRUE',
          'olcAccessLogPurge'   => '07+00:00 01+00:00',
        }),
        require    => Openldap['cn=module{0},cn=config'],
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
      require    => Openldap['cn=module{0},cn=config'],
    }
  }

  if $::openldap::server::smbk5pwd {

    # Install the package before we try and load the module
    if has_key($overlay_packages, 'smbk5pwd') {
      package { $overlay_packages['smbk5pwd']:
        ensure => present,
        before => Openldap['cn=module{0},cn=config'],
      }
    }

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
      require    => Openldap['cn=module{0},cn=config'],
    }
  }

  if $::openldap::server::unique {
    openldap {"olcOverlay=${overlay_index['unique']},olcDatabase={${db_index}}${db_backend},cn=config":
      ensure     => present,
      attributes => delete_undef_values({
        'objectClass'  => [
          'olcOverlayConfig',
          'olcUniqueConfig',
        ],
        'olcOverlay'   => $overlay_index['unique'],
        'olcUniqueURI' => $::openldap::server::unique_uri,
      }),
      require    => Openldap['cn=module{0},cn=config'],
    }
  }

  if $::openldap::server::ppolicy {
    $_ppolicy_hash_cleartext  = $::openldap::server::ppolicy_hash_cleartext ? {
      undef   => undef,
      default => bool2str($::openldap::server::ppolicy_hash_cleartext, 'TRUE', 'FALSE'),
    }
    $_ppolicy_use_lockout     = $::openldap::server::ppolicy_use_lockout ? {
      undef   => undef,
      default => bool2str($::openldap::server::ppolicy_use_lockout, 'TRUE', 'FALSE'),
    }
    $_ppolicy_forward_updates = $::openldap::server::ppolicy_forward_updates ? {
      undef   => undef,
      default => bool2str($::openldap::server::ppolicy_forward_updates, 'TRUE' ,'FALSE'),
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
        'olcPPolicyHashCleartext'  => $_ppolicy_hash_cleartext,
        'olcPPolicyUseLockout'     => $_ppolicy_use_lockout,
        'olcPPolicyForwardUpdates' => $_ppolicy_forward_updates,
      }),
      require    => Openldap['cn=module{0},cn=config'],
    }
  }
}
