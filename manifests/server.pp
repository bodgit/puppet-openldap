# Installs and manages the OpenLDAP server.
#
# @example Create a standalone directory server listening on the standard LDAP TCP port 389 that disallows anonymous reads and allows users to update their own object
#   include ::openldap
#   include ::openldap::client
#
#   class { '::openldap::server':
#     root_dn       => 'cn=Manager,dc=example,dc=com',
#     root_password => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
#     suffix        => 'dc=example,dc=com',
#     access        => [
#       [
#         {
#           'attrs' => ['userPassword'],
#         },
#         [
#           {
#             'who'    => ['self'],
#             'access' => '=xw',
#           },
#           {
#             'who'    => ['anonymous'],
#             'access' => 'auth',
#           },
#         ],
#       ],
#       [
#         {
#           'dn' => '*',
#         },
#         [
#           {
#             'who'    => ['dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth'],
#             'access' => 'manage',
#           },
#           {
#             'who'    => ['self'],
#             'access' => 'write',
#           },
#           {
#             'who'    => ['users'],
#             'access' => 'read',
#           },
#         ],
#       ],
#     ],
#     indices       => [
#       [['objectClass'], ['eq', 'pres']],
#       [['ou', 'cn', 'mail', 'surname', 'givenname'], ['eq', 'pres', 'sub']],
#     ],
#     interfaces    => ["ldap://${::ipaddress}/"],
#   }
#   ::openldap::server::schema { 'cosine':
#     ensure => present,
#   }
#   ::openldap::server::schema { 'inetorgperson':
#     ensure => present,
#   }
#   ::openldap::server::schema { 'nis':
#     ensure  => present,
#     require => ::Openldap::Server::Schema['cosine'],
#   }
#
# @example Extend the above example to become a producer/master server for a number of consumer/slave servers
#   include ::openldap
#   include ::openldap::client
#
#   class { '::openldap::server':
#     root_dn       => 'cn=Manager,dc=example,dc=com',
#     root_password => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
#     suffix        => 'dc=example,dc=com',
#     access        => [
#       [
#         {
#           'attrs' => ['userPassword'],
#         },
#         [
#           {
#             'who'    => ['self'],
#             'access' => '=xw',
#           },
#           {
#             'who'    => ['anonymous'],
#             'access' => 'auth',
#           },
#         ],
#       ],
#       [
#         {
#           'dn' => '*',
#         },
#         [
#           {
#             'who'    => ['dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth'],
#             'access' => 'manage',
#           },
#           {
#             'who'    => ['self'],
#             'access' => 'write',
#           },
#           {
#             'who'    => ['users'],
#             'access' => 'read',
#           },
#         ],
#       ],
#     ],
#     indices       => [
#       [['objectClass'], ['eq', 'pres']],
#       [['ou', 'cn', 'mail', 'surname', 'givenname'], ['eq', 'pres', 'sub']],
#     ],
#     interfaces    => ["ldap://${::ipaddress}/"],
#     replica_dn    => ['cn=replicator,dc=example,dc=com'],
#     syncprov      => true,
#   }
#   ::openldap::server::schema { 'cosine':
#     ensure => present,
#   }
#   ::openldap::server::schema { 'inetorgperson':
#     ensure => present,
#   }
#   ::openldap::server::schema { 'nis':
#     ensure  => present,
#     require => ::Openldap::Server::Schema['cosine'],
#   }
#
# @example Extend this further to also enable delta replication
#   include ::openldap
#   include ::openldap::client
#
#   class { '::openldap::server':
#     root_dn       => 'cn=Manager,dc=example,dc=com',
#     root_password => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
#     suffix        => 'dc=example,dc=com',
#     access        => [
#       [
#         {
#           'attrs' => ['userPassword'],
#         },
#         [
#           {
#             'who'    => ['self'],
#             'access' => '=xw',
#           },
#           {
#             'who'    => ['anonymous'],
#             'access' => 'auth',
#           },
#         ],
#       ],
#       [
#         {
#           'dn' => '*',
#         },
#         [
#           {
#             'who'    => ['dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth'],
#             'access' => 'manage',
#           },
#           {
#             'who'    => ['self'],
#             'access' => 'write',
#           },
#           {
#             'who'    => ['users'],
#             'access' => 'read',
#           },
#         ],
#       ],
#     ],
#     accesslog     => true,
#     indices       => [
#       [['objectClass'], ['eq', 'pres']],
#       [['ou', 'cn', 'mail', 'surname', 'givenname'], ['eq', 'pres', 'sub']],
#     ],
#     interfaces    => ["ldap://${::ipaddress}/"],
#     replica_dn    => ['cn=replicator,dc=example,dc=com'],
#     syncprov      => true,
#   }
#   ::openldap::server::schema { 'cosine':
#     ensure => present,
#   }
#   ::openldap::server::schema { 'inetorgperson':
#     ensure => present,
#   }
#   ::openldap::server::schema { 'nis':
#     ensure  => present,
#     require => ::Openldap::Server::Schema['cosine'],
#   }
#
# @example Create a server acting as a consumer of another server using delta replication and pass back a referral to clients on attempting to write
#   include ::openldap
#   include ::openldap::client
#
#   class { '::openldap::server':
#     root_dn       => 'cn=Manager,dc=example,dc=com',
#     root_password => '{SSHA}7dSAJPGe4YKKEvUPuGJIeSL/03GV2IMY',
#     suffix        => 'dc=example,dc=com',
#     access        => [
#       [
#         {
#           'attrs' => ['userPassword'],
#         },
#         [
#           {
#             'who'    => ['self'],
#             'access' => '=xw',
#           },
#           {
#             'who'    => ['anonymous'],
#             'access' => 'auth',
#           },
#         ],
#       ],
#       [
#         {
#           'dn' => '*',
#         },
#         [
#           {
#             'who'    => ['dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth'],
#             'access' => 'manage',
#           },
#           {
#             'who'    => ['self'],
#             'access' => 'write',
#           },
#           {
#             'who'    => ['users'],
#             'access' => 'read',
#           },
#         ],
#       ],
#     ],
#     indices       => [
#       [['objectClass'], ['eq', 'pres']],
#       [['ou', 'cn', 'mail', 'surname', 'givenname'], ['eq', 'pres', 'sub']],
#     ],
#     interfaces    => ["ldap://${::ipaddress}/"],
#     syncrepl      => [
#       {
#         'rid'            => 1,
#         'provider'       => 'ldap://ldap.example.com/',
#         'searchbase'     => 'dc=example,dc=com',
#         'bindmethod'     => 'simple',
#         'binddn'         => 'cn=replicator,dc=example,dc=com',
#         'credentials'    => 'secret',
#         'logbase'        => 'cn=log',
#         'logfilter'      => '(&(objectClass=auditWriteObject)(reqResult=0))',
#         'schemachecking' => true,
#         'type'           => 'refreshAndPersist',
#         'retry'          => [[60, '+']],
#         'syncdata'       => 'accesslog',
#       },
#     ],
#     update_ref    => ['ldap://ldap.example.com/'],
#   }
#   ::openldap::server::schema { 'cosine':
#     ensure => present,
#   }
#   ::openldap::server::schema { 'inetorgperson':
#     ensure => present,
#   }
#   ::openldap::server::schema { 'nis':
#     ensure  => present,
#     require => ::Openldap::Server::Schema['cosine'],
#   }
#
# @param root_dn The Root Distinguished Name used to administer the database.
# @param root_password The password for the Root Distinguished Name.
# @param suffix The suffix for the main database.
# @param access An array of ACLs to apply to the database, in the same form as
#   the `olcAccess` attribute.
#
#   Do not include an ACL for the DN used by replication, one is added
#   automatically when the `syncprov` parameter is used.
# @param accesslog Setting this to `true` will enable the `accesslog` overlay
#   in conjunction with the `syncprov` overlay to enable delta replication.
#
#   It will create a separate database with the suffix `cn=log` and use the
#   value of the `replica_dn` parameter much like the `syncprov` setting to
#   allow it to be accessed by consumers.
# @param accesslog_cachesize Specify the size of the in-memory entry cache
#   maintained by the `bdb` or `hdb` backends for the database used by the
#   `accesslog` overlay. See the `olcDbCacheSize` attribute.
# @param accesslog_checkpoint Specify the frequency for checkpointing the
#   transaction log of the database used by the `accesslog` overlay. This is
#   specified in the same form as the `olcDbCheckpoint` attribute.
# @param accesslog_db_config An array of lines in the same form as the
#   `olcDbConfig` attribute to tune the database used by the `accesslog`
#   overlay. This results in creating a `DB_CONFIG` file for the database if
#   the backend is either `bdb` or `hdb`.
# @param accesslog_dn_cachesize Specify the size of the in-memory DN cache
#   maintained by the `bdb` or `hdb` backends for the database used by the
#   `accesslog` overlay. See the `olcDbDNcacheSize` attribute.
# @param accesslog_envflags An array of flags for configuring the LMDB library
#   used by the `mdb` backend.
# @param accesslog_index_cachesize Specify the size of the in-memory index
#   cache maintained by the `bdb` or `hdb` backends for the database used by
#   the `accesslog` overlay. See the `olcDbIDLcacheSize` attribute.
# @param args_file Where `slapd` writes out its command-line arguments.
# @param auditlog Setting this to `true` will enable the `auditlog` overlay.
# @param auditlog_file The LDIF file where the `auditlog` overlay writes any
#   changes.
# @param authz_policy Maps to the `olcAuthzPolicy` attribute, accepts one of
#   `none`, `from`, `to`, `any`, or `all`.
# @param backend_modules An array of database backends that are built as
#   modules and therefore require loading before use. The backend names are
#   listed without the `back_` prefix and any extension that the module
#   filename might have.
# @param backend_packages A hash keyed by database backend with the package
#   name that provides it as the value. As with `backend_modules` the backend
#   is used without any `back_` prefix and any extension that the module
#   filename might have.
# @param chain Setting this to `true` enables the `chain` overlay which
#   transparently forwards writes to a slave/consumer on behalf of the client
#   to the master/producer indicated by the configured update referral URI.
# @param chain_id_assert_bind Maps to the `olcDbIDAssertBind` attribute on the
#   LDAP database used by the chain overlay.
# @param chain_rebind_as_user Maps to the `olcDbRebindAsUser` attribute on the
#   LDAP database used by the chain overlay.
# @param chain_return_error Maps to the `olcChainReturnError` attribute on the
#   chain overlay.
# @param chain_tls Maps to the `olcDbStartTLS` attribute on the LDAP database
#   used by the chain overlay. See the `tls` entry in the `slapd-ldap` man page
#   for more information on usage and accepted values.
# @param data_cachesize Specify the size of the in-memory entry cache
#   maintained by the `bdb` or `hdb` backends for the main database. See the
#   `olcDbCacheSize` attribute.
# @param data_checkpoint Specify the frequency for checkpointing the
#   transaction log of the main database. This is specified in the same form as
#   the `olcDbCheckpoint` attribute.
# @param data_db_config An array of lines in the same form as the `olcDbConfig`
#   attribute to tune the main database. This results in creating a `DB_CONFIG`
#   file for the database if the backend is either `bdb` or `hdb`.
# @param data_directory The base directory used for database storage. Rather
#   than store one database at the top level, this module creates a
#   sub-directory per-database. Any unmanaged files in the top-level directory
#   will be purged.
# @param data_dn_cachesize Specify the size of the in-memory index cache
#   maintained by the `bdb` or `hdb` backends for the main database. See the
#   `olcDbDNcacheSize` attribute.
# @param data_envflags An array of flags for configuring the LMDB library used
#   by the `mdb` backend.
# @param data_index_cachesize Specify the size of the in-memory index cache
#   maintained by the `bdb` or `hdb` backends for the main database. See the
#   `olcDbIDLcacheSize` attribute.
# @param db_backend The chosen database backend, usually one of `hdb`, `bdb`,
#   or `mdb`.
# @param group The group that runs the `slapd` process.
# @param indices An array of index definitions in the same form as the
#   `olcDbIndex` attribute.
#
#   Do not include an index for the attributes applicable to the `syncprov`
#   overlay. They are added automatically.
# @param interfaces An array of `ldap:///` and/or `ldaps:///` URI's to listen
#   on.
# @param limits An array of limits in the same form as the `olcLimits`
#   attribute.
#
#   Do not include a limit for the DN used by replication, one is added
#   automatically when the `syncprov` parameter is used.
# @param local_ssf Security strength factor assigned to `ldapi` connections.
#   This defaults to 256 which is a safeguard to prevent locking the Puppet
#   agent out as it uses this connection to manipulate the configuration.
# @param log_level Set the logging level. Maps to the `olcLogLevel` attribute.
# @param memberof Setting this to `true` enables the memberOf overlay. See the
#   entry in `slapo-memberof(5)` man page for more details.
# @param module_extension The extension module files have, normally `.la`.
# @param overlay_modules A list of overlays by name that are modules.
# @param overlay_packages A hash keyed by overlay name with the package name
#   that provides it as the value.
# @param package_ensure The standard package `ensure` parameter, usually
#   `present`.
# @param package_name The name of the package to install that provides the LDAP
#   `slapd` daemon.
# @param password_crypt_salt_format The format of the salt for hashing user
#   passwords. Corresponds to the `olcPasswordCryptSaltFormat` attribute. See
#   the entry in the `slapd-config(5)` man page for formatting details.
# @param password_hash The password hashing scheme to use for user passwords.
#   Can be set to a list containing any of the following:
#
#   * `{SSHA}`, `{SHA}`
#   * `{SMD5}`, `{MD5}`
#   * `{CRYPT}`
#   * `{CLEARTEXT}`
#
#   The following schemes are also accepted however this requires additional
#   modules to be loaded which are often not available by default:
#
#   * `{SSHA256}`, `{SSHA384}`, `{SSHA512}`, `{SHA256}`, `{SHA384}`, `{SHA512}`
#   * `{TOTP1}`, `{TOTP256}`, `{TOTP512}`
#   * `{PBKDF2}`, `{PBKDF2-SHA1}`, `{PBKDF2-SHA256}`, `{PBKDF2-SHA512}`
#   * `{BSDMD5}`
#   * `{NS-MTA-MD5}`
#   * `{APR1}`
#   * `{RADIUS}`
#   * `{KERBEROS}`
#
#   If this is not set, LDAP uses `{SSHA}` by default. Corresponds to the
#   `olcPasswordHash` attribute.
# @param password_modules A hash keyed by password hashing scheme with the
#   module name that provides it as the value. The hashing scheme is listed
#   complete with enclosing `{}`'s and the value is listed without any
#   extension that the module filename might have.
# @param password_packages A hash keyed by any values in `password_modules`
#   with the package name that provides it as the value.
# @param pid_file Where `slapd` writes out its PID.
# @param ppolicy Setting this to `true` will enable the `ppolicy` overlay on
#   the main database allowing the enforcement of password strength/complexity
#   as well as account lockout. The `ppolicy` schema will be loaded
#   automatically.
# @param ppolicy_default A Distinguished Name of the default password policy
#   object to use if a user does not have a `pwdPolicySubEntry` attribute. This
#   must exist under the main suffix.
# @param ppolicy_forward_updates If this server is a consumer/slave this
#   setting controls whether password policy operational attributes are written
#   locally or forwarded to the producer/master, (which means they can come
#   back via replication). This requires enabling the `chain` overlay.
# @param ppolicy_hash_cleartext Setting this to `true` forces cleartext
#   passwords to be hashed when updated via Add or Modify operations. This is
#   not necessary if the Password Modify extended operation is normally used.
# @param ppolicy_use_lockout Setting this to `true` makes a bind to a locked
#   account return an `AccountLocked` error instead of `InvalidCredentials`.
# @param refint Setting this to `true` will enable the `refint` overlay on the
#   main database allowing referential integrity on attribute values.
# @param refint_attributes Array of attributes for which integrity will be
#   maintained.
# @param refint_nothing Arbitrary value to be used as a placeholder when the
#   last value would otherwise be deleted.
# @param replica_dn The Distinguished Names used by consumer/slave servers to
#   connect to this server in order to replicate content.
# @param schema_dir The base directory used to store the schemas shipped with
#   OpenLDAP. This is used as a default by the `openldap::server::schema`
#   defined type.
# @param security Specify minimum security strength factors in the same form as
#   the `olcSecurity` attribute.
# @param size_limit Specify the maximum number of entries to return from a
#   search operation. Maps to the `olcSizeLimit` attribute set on the `frontend`
#   database.
# @param smbk5pwd Setting this to `true` will enable the `smbk5pwd` overlay. In
#   order to add this overlay to the database, the schema files for any enabled
#   backends also need to be loaded. Both Red Hat and Debian/Ubuntu enable the
#   Samba backend by default which requires the Samba schema. Debian/Ubuntu
#   additionally enable the Kerberos backend which requires the Heimdal KDC/HDB
#   schema and also `slapd` will need to be able to access the KDC master key
#   (`m-key`) file.
# @param smbk5pwd_backends By default, all backends compiled into the overlay
#   are enabled. Pass in an array of backends to enable only some of them. This
#   affects which schemas need to be loaded and any additional setup steps. This
#   maps to the `olcSmbK5PwdEnable` attribute.
# @param smbk5pwd_must_change Maps to the `olcSmbK5PwdMustChange` attribute
#   controlling how long until Samba passwords expire after a password change.
# @param ssl_ca Maps to the `olcTLSCACertificateFile` attribute.
# @param ssl_cert Maps to the `olcTLSCertificateFile` attribute.
# @param ssl_certs_dir Maps to the `olcTLSCACertificatePath` attribute.
# @param ssl_cipher Maps to the `olcTLSCipherSuite` attribute.
# @param ssl_dhparam Maps to the `olcTLSDHParamFile` attribute.
# @param ssl_key Maps to the `olcTLSCertificateKeyFile` attribute.
# @param ssl_protocol Maps to the `olcTLSProtocolMin` attribute.
# @param syncprov Setting this to `true` will enable the `syncprov` overlay on
#   the main database allowing consumer/slave servers to replicate the content.
#
#   An additional index `entryCSN,entryUUID eq` will be appended to those passed
#   by the `indices` parameter.
#
#   The value of the `replica_dn` parameter is also used to prepend the ACL `to
#   * by dn.exact="${replica_dn}" read by * break` to those passed by the
#   `access` parameter to allow the consumers to read all of the data. The limit
#   `dn.exact="${replica_dn}" time.soft=unlimited time.hard=unlimited
#   size.soft=unlimited size.hard=unlimited` is also prepended to any limits
#   passed with the `limits` parameter.
# @param syncprov_checkpoint Maps to the `olcSpCheckpoint` attribute.
# @param syncprov_sessionlog Maps to the `olcSpSessionlog` attribute.
# @param syncrepl An array of `olcSyncrepl` attribute values used to establish
#   a replication relationship between this server and a producer.
# @param time_limit Specify the maximum number of seconds `slapd` will spend
#   answering a search request. Maps to the `olcTimeLimit` attribute set on the
#   `frontend` database.
# @param unique Setting this to `true` will enable the `unique` overlay on the
#   main database allowing the enforcement of attribute value uniqueness.
# @param unique_uri Maps to the `olcUniqueURI` attribute.
# @param update_ref One or more referral URI's to return for referring writes
#   from a read-only replica server to the original producer/master server.
#   These are used to configure the `chain` overlay.
# @param user The user that runs the `slapd` process.
#
# @see puppet_classes::openldap ::openldap
# @see puppet_classes::openldap::client ::openldap::client
# @see puppet_defined_types::openldap::server::schema ::openldap::server::schema
class openldap::server (
  Bodgitlib::LDAP::DN                                 $root_dn,
  String                                              $root_password,
  Bodgitlib::LDAP::DN                                 $suffix,
  Array[OpenLDAP::Access, 1]                          $access                     = $::openldap::params::access,
  Boolean                                             $accesslog                  = false,
  Optional[Integer[0]]                                $accesslog_cachesize        = undef,
  Optional[OpenLDAP::Checkpoint]                      $accesslog_checkpoint       = undef,
  Optional[Array[String, 1]]                          $accesslog_db_config        = undef,
  Optional[Integer[0]]                                $accesslog_dn_cachesize     = undef,
  Optional[Array[String, 1]]                          $accesslog_envflags         = undef,
  Optional[Integer[0]]                                $accesslog_index_cachesize  = undef,
  Stdlib::Absolutepath                                $args_file                  = $::openldap::params::args_file,
  Boolean                                             $auditlog                   = false,
  Optional[Stdlib::Absolutepath]                      $auditlog_file              = undef,
  Optional[Enum['none', 'from', 'to', 'any', 'all']]  $authz_policy               = undef,
  Array[OpenLDAP::Backend]                            $backend_modules            = $::openldap::params::backend_modules,
  Hash[OpenLDAP::Backend, String]                     $backend_packages           = $::openldap::params::backend_packages,
  Boolean                                             $chain                      = false,
  Optional[OpenLDAP::LDAP::IDAssertBind]              $chain_id_assert_bind       = undef,
  Optional[Boolean]                                   $chain_rebind_as_user       = undef,
  Optional[Boolean]                                   $chain_return_error         = undef,
  Optional[OpenLDAP::LDAP::TLS]                       $chain_tls                  = undef,
  Optional[Integer[0]]                                $data_cachesize             = undef,
  Optional[OpenLDAP::Checkpoint]                      $data_checkpoint            = undef,
  Optional[Array[String, 1]]                          $data_db_config             = undef,
  Stdlib::Absolutepath                                $data_directory             = $::openldap::params::data_directory,
  Optional[Integer[0]]                                $data_dn_cachesize          = undef,
  Optional[Array[String, 1]]                          $data_envflags              = undef,
  Optional[Integer[0]]                                $data_index_cachesize       = undef,
  OpenLDAP::Backend                                   $db_backend                 = $::openldap::params::db_backend,
  String                                              $group                      = $::openldap::params::group,
  Optional[Array[OpenLDAP::Index, 1]]                 $indices                    = undef,
  Optional[Array[Bodgitlib::LDAP::URI::Simple, 1]]    $interfaces                 = $::openldap::params::interfaces,
  Optional[Array[OpenLDAP::Limit, 1]]                 $limits                     = undef,
  Optional[Integer[0]]                                $local_ssf                  = $::openldap::params::local_ssf,
  Optional[Array[OpenLDAP::LogLevel, 1]]              $log_level                  = undef,
  String                                              $module_extension           = $::openldap::params::module_extension,
  Boolean                                             $memberof                   = false,
  Array[OpenLDAP::Overlay]                            $overlay_modules            = $::openldap::params::overlay_modules,
  Hash[OpenLDAP::Overlay, String]                     $overlay_packages           = $::openldap::params::overlay_packages,
  String                                              $package_ensure             = $::openldap::params::server_package_ensure,
  String                                              $package_name               = $::openldap::params::server_package_name,
  Optional[String]                                    $password_crypt_salt_format = undef,
  Optional[Array[OpenLDAP::PasswordHash, 1]]          $password_hash              = undef,
  Hash[OpenLDAP::PasswordHash, String]                $password_modules           = $::openldap::params::password_modules,
  Hash[String, String]                                $password_packages          = $::openldap::params::password_packages,
  Stdlib::Absolutepath                                $pid_file                   = $::openldap::params::pid_file,
  Boolean                                             $ppolicy                    = false,
  Optional[Bodgitlib::LDAP::DN]                       $ppolicy_default            = undef,
  Optional[Boolean]                                   $ppolicy_forward_updates    = undef,
  Optional[Boolean]                                   $ppolicy_hash_cleartext     = undef,
  Optional[Boolean]                                   $ppolicy_use_lockout        = undef,
  Boolean                                             $refint                     = false,
  Optional[Array[String, 1]]                          $refint_attributes          = undef,
  Optional[Bodgitlib::LDAP::DN]                       $refint_nothing             = undef,
  Optional[Array[Bodgitlib::LDAP::DN, 1]]             $replica_dn                 = undef,
  Stdlib::Absolutepath                                $schema_dir                 = $::openldap::params::schema_dir,
  Optional[OpenLDAP::Security]                        $security                   = undef,
  Optional[OpenLDAP::Limit::Size]                     $size_limit                 = undef,
  Boolean                                             $smbk5pwd                   = false,
  Optional[Array[Enum['krb5', 'samba', 'shadow'], 1]] $smbk5pwd_backends          = undef,
  Optional[Integer[0]]                                $smbk5pwd_must_change       = undef,
  Optional[Stdlib::Absolutepath]                      $ssl_ca                     = undef,
  Optional[Stdlib::Absolutepath]                      $ssl_cert                   = undef,
  Optional[Stdlib::Absolutepath]                      $ssl_certs_dir              = undef,
  Optional[String]                                    $ssl_cipher                 = undef,
  Optional[Stdlib::Absolutepath]                      $ssl_dhparam                = undef,
  Optional[Stdlib::Absolutepath]                      $ssl_key                    = undef,
  Optional[Variant[Integer[0], Float[0]]]             $ssl_protocol               = undef,
  Boolean                                             $syncprov                   = false,
  Optional[OpenLDAP::Checkpoint]                      $syncprov_checkpoint        = $::openldap::params::syncprov_checkpoint,
  Optional[Integer[0]]                                $syncprov_sessionlog        = $::openldap::params::syncprov_sessionlog,
  Optional[Array[OpenLDAP::Syncrepl, 1]]              $syncrepl                   = undef,
  Optional[OpenLDAP::Limit::Time]                     $time_limit                 = undef,
  Boolean                                             $unique                     = false,
  Optional[Array[OpenLDAP::Unique, 1]]                $unique_uri                 = undef,
  Optional[Array[Bodgitlib::LDAP::URI::Simple, 1]]    $update_ref                 = undef,
  String                                              $user                       = $::openldap::params::user,
) inherits ::openldap::params {

  if ! (defined(Class['::openldap']) or defined(Class['::openldap::client'])) {
    fail('You must include either the openldap or openldap::client class as appropriate before using the openldap::server class')
  }

  if $auditlog and ! $auditlog_file {
    fail('Audit Logging ovelay requires a log file')
  }

  if $chain and ! $update_ref {
    fail('Chain overlay requires an update referral URL')
  }

  if $refint and ! $refint_attributes {
    fail('Referential Integrity overlay requires attributes')
  }

  if $syncprov and ! $replica_dn {
    fail('Sync Provider overlay requires a replica DN')
  }

  contain ::openldap::server::install
  contain ::openldap::server::config
  contain ::openldap::server::service

  Class['::openldap::server::install'] -> Class['::openldap::server::service']
  Class['::openldap::server::install'] -> Class['::openldap::server::config']
}
