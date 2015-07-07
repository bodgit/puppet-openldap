#
class openldap::server::config {

  $backend_modules  = $::openldap::server::backend_modules
  $data_directory   = $::openldap::server::data_directory
  $db_backend       = $::openldap::server::db_backend
  $group            = $::openldap::server::group
  $module_extension = $::openldap::server::module_extension
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
      file { '/etc/sysconfig/slapd':
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
    attributes => {
      'cn'                       => 'config',
      'objectClass'              => 'olcGlobal',
      'olcArgsFile'              => $::openldap::server::args_file,
      'olcLocalSSF'              => $::openldap::server::local_ssf,
      'olcPidFile'               => $::openldap::server::pid_file,
      'olcSecurity'              => $::openldap::server::security,
      'olcTLSCACertificateFile'  => $::openldap::server::ssl_ca,
      'olcTLSCACertificatePath'  => $::openldap::server::ssl_certs_dir,
      'olcTLSCertificateFile'    => $::openldap::server::ssl_cert,
      'olcTLSCertificateKeyFile' => $::openldap::server::ssl_key,
      'olcTLSCipherSuite'        => $::openldap::server::ssl_cipher,
      'olcTLSDHParamFile'        => $::openldap::server::ssl_dhparam,
      'olcTLSProtocolMin'        => $::openldap::server::ssl_protocol,
    },
  }

  $module_candidates = [
    member($backend_modules, 'monitor') ? {
      true    => 'back_monitor',
      default => '',
    },
    member($backend_modules, $db_backend) ? {
      true    => "back_${db_backend}",
      default => '',
    },
    $::openldap::server::syncprov ? {
      true    => 'syncprov',
      default => '',
    },
    $::openldap::server::accesslog ? {
      true    => 'accesslog',
      default => '',
    },
    $::openldap::server::auditlog ? {
      true    => 'auditlog',
      default => '',
    }
  ]

  $modules = reject($module_candidates, '^\s*$')

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
    attributes => {
      'objectClass' => [
        'olcDatabaseConfig',
        'olcFrontendConfig',
      ],
      'olcDatabase' => '{-1}frontend',
    },
  }

  openldap { 'olcDatabase={0}config,cn=config':
    ensure     => present,
    attributes => {
      'objectClass' => 'olcDatabaseConfig',
      'olcAccess'   => '{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by * none', # lint:ignore:80chars
      'olcDatabase' => '{0}config',
    },
  }

  openldap { 'olcDatabase={1}monitor,cn=config':
    ensure     => present,
    attributes => {
      'objectClass' => 'olcDatabaseConfig',
      'olcAccess'   => '{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by * none', # lint:ignore:80chars
      'olcDatabase' => '{1}monitor',
    },
    require    => Openldap['cn=module{0},cn=config'],
  }

  # Assume foo backend uses olcFooConfig class, works for *db at least
  $object_class = sprintf('olc%sConfig', capitalize($db_backend))

  # syncprov overlay is required, i.e. this is a master/producer
  if $::openldap::server::syncprov {

    $replica_access   = "to * by dn.exact=\"${replica_dn}\" read"
    $replica_limits   = "dn.exact=\"${replica_dn}\" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited" # lint:ignore:80chars

    # Prepend replica ACL to any on the main database and also create indices
    # required by the overlay
    $access  = flatten(["${replica_access} by * break",
      $::openldap::server::access])
    $indices = flatten([$::openldap::server::indices, 'entryCSN,entryUUID eq'])
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
        attributes => {
          'objectClass'       => [
            'olcDatabaseConfig',
            $object_class,
          ],
          'olcAccess'         => openldap_values($replica_access),
          'olcDatabase'       => "{2}${db_backend}",
          'olcDbCacheSize'    => $::openldap::server::accesslog_cachesize,
          'olcDbCheckpoint'   => $::openldap::server::accesslog_checkpoint,
          'olcDbConfig'       => openldap_values($::openldap::server::accesslog_db_config), # lint:ignore:80chars
          'olcDbDirectory'    => "${data_directory}/log",
          'olcDbDNcacheSize'  => $::openldap::server::accesslog_dn_cachesize,
          'olcDbIDLcacheSize' => $::openldap::server::accesslog_index_cachesize,
          'olcDbIndex'        => [
            'entryCSN,objectClass,reqEnd,reqResult,reqStart eq',
          ],
          'olcLimits'         => openldap_values($replica_limits),
          'olcRootDN'         => $::openldap::server::root_dn,
          'olcSuffix'         => 'cn=log',
        },
        require    => Openldap['cn=module{0},cn=config'],
      }

      openldap { "olcOverlay={0}syncprov,olcDatabase={2}${db_backend},cn=config": # lint:ignore:80chars
        ensure     => present,
        attributes => {
          'objectClass'     => [
            'olcOverlayConfig',
            'olcSyncProvConfig',
          ],
          'olcOverlay'      => '{0}syncprov',
          'olcSpCheckpoint' => $::openldap::server::syncprov_checkpoint,
          'olcSpNoPresent'  => 'TRUE',
          'olcSpReloadHint' => 'TRUE',
          'olcSpSessionlog' => $::openldap::server::syncprov_sessionlog,
        },
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
      $indices = flatten([$::openldap::server::indices,
        'entryCSN,entryUUID eq'])
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
    attributes => {
      'objectClass'       => [
        'olcDatabaseConfig',
        $object_class,
      ],
      'olcAccess'         => openldap_values($access),
      'olcDatabase'       => "{${db_index}}${db_backend}",
      'olcDbCacheSize'    => $::openldap::server::data_cachesize,
      'olcDbCheckpoint'   => $::openldap::server::data_checkpoint,
      'olcDbConfig'       => openldap_values($::openldap::server::data_db_config), # lint:ignore:80chars
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
      'olcUpdateRef'      => openldap_values($::openldap::server::update_ref),
    },
    require    => Openldap['cn=module{0},cn=config'],
  }

  if $::openldap::server::syncprov {
    openldap { "olcOverlay={0}syncprov,olcDatabase={${db_index}}${db_backend},cn=config": # lint:ignore:80chars
      ensure     => present,
      attributes => {
        'objectClass'     => [
          'olcOverlayConfig',
          'olcSyncProvConfig',
        ],
        'olcOverlay'      => '{0}syncprov',
        'olcSpCheckpoint' => $::openldap::server::syncprov_checkpoint,
        'olcSpReloadHint' => 'TRUE',
        'olcSpSessionlog' => $::openldap::server::syncprov_sessionlog,
      },
      require    => Openldap['cn=module{0},cn=config'],
    }

    if $::openldap::server::accesslog {
      openldap { "olcOverlay={1}accesslog,olcDatabase={${db_index}}${db_backend},cn=config": # lint:ignore:80chars
        ensure     => present,
        attributes => {
          'objectClass'         => [
            'olcOverlayConfig',
            'olcAccessLogConfig',
          ],
          'olcOverlay'          => '{1}accesslog',
          'olcAccessLogDB'      => 'cn=log',
          'olcAccessLogOps'     => 'writes',
          'olcAccessLogSuccess' => 'TRUE',
          'olcAccessLogPurge'   => '07+00:00 01+00:00',
        },
        require    => Openldap['cn=module{0},cn=config'],
      }

      $overlay_index = 2
    } else {
      $overlay_index = 1
    }
  } else {
    $overlay_index = 0
  }

  if $::openldap::server::auditlog {
    openldap { "olcOverlay={${overlay_index}}auditlog,olcDatabase={${db_index}}${db_backend},cn=config": # lint:ignore:80chars
      ensure     => present,
      attributes => {
        'objectClass'     => [
          'olcOverlayConfig',
          'olcAuditlogConfig',
        ],
        'olcOverlay'      => "{${overlay_index}}auditlog",
        'olcAuditlogFile' => $::openldap::server::auditlog_file,
      },
      require    => Openldap['cn=module{0},cn=config'],
    }
  }
}
