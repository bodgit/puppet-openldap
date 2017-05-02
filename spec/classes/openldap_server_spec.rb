require 'spec_helper'

describe 'openldap::server' do

  let(:params) do
    {
      :root_dn                    => 'cn=Manager,dc=example,dc=com',
      :root_password              => 'secret',
      :suffix                     => 'dc=example,dc=com',
      :accesslog                  => true,
      :accesslog_cachesize        => 1000,
      :accesslog_checkpoint       => [100, 10],
      :accesslog_db_config        => [
        'set_cachesize 0 2097152 0',
        'set_lk_max_objects 1500',
        'set_lk_max_locks 1500',
        'set_lk_max_lockers 1500',
      ],
      :accesslog_dn_cachesize     => 100,
      :accesslog_index_cachesize  => 300,
      :auditlog                   => true,
      :auditlog_file              => '/tmp/auditlog.ldif',
      :authz_policy               => 'none',
      :chain                      => true,
      :chain_id_assert_bind       => {
        'bindmethod' => 'simple',
      },
      :chain_rebind_as_user       => true,
      :chain_return_error         => true,
      :chain_tls                  => {
        'mode' => 'start',
      },
      :data_cachesize             => 1000,
      :data_checkpoint            => [100, 10],
      :data_db_config             => [
        'set_cachesize 0 2097152 0',
        'set_lk_max_objects 1500',
        'set_lk_max_locks 1500',
        'set_lk_max_lockers 1500',
      ],
      :data_dn_cachesize          => 100,
      :data_index_cachesize       => 300,
      :indices                    => [
        [['objectClass'], ['eq', 'pres']],
      ],
      :limits                     => [
        {
          'selector' => 'users',
          'size'     => 'unlimited',
          'time'     => {
            'soft' => 0,
            'hard' => 'unlimited',
          },
        },
      ],
      :log_level                  => [
        128,
        'filter',
        0x1,
      ],
      :memberof                   => true,
      :password_crypt_salt_format => '%.2s',
      :password_hash              => [
        '{SSHA512}',
        '{SSHA}',
      ],
      :ppolicy                    => true,
      :ppolicy_default            => 'cn=passwordDefault,dc=example,dc=com',
      :ppolicy_forward_updates    => true,
      :ppolicy_hash_cleartext     => true,
      :ppolicy_use_lockout        => false,
      :refint                     => true,
      :refint_attributes          => ['manager'],
      :refint_nothing             => 'cn=empty,dc=example,dc=com',
      :replica_dn                 => [
        'cn=replica,dc=example,dc=com',
      ],
      :security                   => {
        'ssf'         => 256,
        'simple_bind' => 128,
      },
      :size_limit                 => {
        'soft' => 0,
        'hard' => 'unlimited',
      },
      :smbk5pwd                   => true,
      :smbk5pwd_backends          => ['samba'],
      :smbk5pwd_must_change       => 2592000,
      :ssl_ca                     => '/tmp/cacert.pem',
      :ssl_cert                   => '/tmp/cert.pem',
      :ssl_certs_dir              => '/tmp/certs',
      :ssl_cipher                 => 'HIGH:MEDIUM:+SSLv2',
      :ssl_dhparam                => '/tmp/dhparam.pem',
      :ssl_key                    => '/tmp/key.pem',
      :ssl_protocol               => 3.2,
      :syncprov                   => true,
      :syncrepl                   => [
        {
          'rid'        => 1,
          'provider'   => 'ldap://ldap.example.com/',
          'searchbase' => 'dc=example,dc=com',
        },
      ],
      :time_limit                 => 'unlimited',
      :unique                     => true,
      :unique_uri                 => [
        {
          'strict' => true,
          'ignore' => true,
          'uri'    => [
            'ldap:///dc=example,dc=com?uidNumber?sub',
          ],
        },
      ],
      :update_ref                 => [
        'ldap://ldap.example.com/',
      ],
    }
  end

  context 'without openldap::client class included' do
    let(:facts) do
      {
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => 7,
      }
    end

    it { expect { should compile }.to raise_error(/must include either the openldap or openldap::client class/) }
  end

  context 'with openldap::client class included' do
    let(:pre_condition) do
      <<-EOF
        include ::openldap
        if $::osfamily != 'OpenBSD' {
          include ::openldap::client
        }
      EOF
    end

    on_supported_os.each do |os, facts|
      context "on #{os}", :compile do
        let(:facts) do
          facts
        end

        it { should contain_class('openldap::server') }
        it { should contain_class('openldap::server::config') }
        it { should contain_class('openldap::server::install') }
        it { should contain_class('openldap::server::service') }
        it { should contain_openldap('cn=schema,cn=config').with_attributes(
          {
            'objectClass' => ['olcSchemaConfig'],
            'cn'          => ['schema'],
          }
        ) }
        it { should contain_openldap('olcDatabase={0}config,cn=config').with_attributes(
          {
            'objectClass' => ['olcDatabaseConfig'],
            'olcAccess'   => ['{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by * none'],
            'olcDatabase' => ['{0}config'],
            'olcLimits'   => ['{0}dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'],
          }
        ) }
        it { should contain_openldap('olcDatabase={-1}frontend,cn=config').with_attributes(
          {
            'objectClass'     => [
              'olcDatabaseConfig',
              'olcFrontendConfig',
            ],
            'olcDatabase'     => ['{-1}frontend'],
            'olcSizeLimit'    => ['size.soft=0 size.hard=unlimited'],
            'olcTimeLimit'    => ['unlimited'],
            'olcPasswordHash' => ['{SSHA512} {SSHA}'],
          }
        ) }
        it { should contain_openldap('olcOverlay={0}chain,olcDatabase={-1}frontend,cn=config').with_attributes(
          {
            'objectClass'         => [
              'olcOverlayConfig',
              'olcChainConfig',
            ],
            'olcOverlay'          => ['{0}chain'],
            'olcChainReturnError' => ['TRUE'],
          }
        ) }
        it { should contain_openldap('olcDatabase={0}ldap,olcOverlay={0}chain,olcDatabase={-1}frontend,cn=config').with_attributes(
          {
            'objectClass'       => [
              'olcLDAPConfig',
              'olcChainDatabase',
            ],
            'olcDatabase'       => ['{0}ldap'],
            'olcDbURI'          => ['ldap://ldap.example.com/'],
            'olcDbRebindAsUser' => ['TRUE'],
            'olcDbIDAssertBind' => ['bindmethod=simple'],
            'olcDbStartTLS'     => ['start']
          }
        ) }
        it { should contain_openldap('olcDatabase={1}monitor,cn=config').with_attributes(
          {
            'objectClass' => ['olcDatabaseConfig'],
            'olcAccess'   => ['{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by * none'],
            'olcDatabase' => ['{1}monitor'],
          }
        ) }
        it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={2}hdb,cn=config').with_attributes(
          {
            'objectClass'     => [
              'olcOverlayConfig',
              'olcSyncProvConfig',
            ],
            'olcOverlay'      => ['{0}syncprov'],
            'olcSpCheckpoint' => ['100 10'],
            'olcSpNoPresent'  => ['TRUE'],
            'olcSpReloadHint' => ['TRUE'],
            'olcSpSessionlog' => ['100'],
          }
        ) }
        it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={3}hdb,cn=config').with_attributes(
          {
            'objectClass'     => [
              'olcOverlayConfig',
              'olcSyncProvConfig',
            ],
            'olcOverlay'      => ['{0}syncprov'],
            'olcSpCheckpoint' => ['100 10'],
            'olcSpReloadHint' => ['TRUE'],
            'olcSpSessionlog' => ['100'],
          }
        ) }
        it { should contain_openldap('olcOverlay={1}accesslog,olcDatabase={3}hdb,cn=config').with_attributes(
          {
            'objectClass'         => [
              'olcOverlayConfig',
              'olcAccessLogConfig',
            ],
            'olcOverlay'          => ['{1}accesslog'],
            'olcAccessLogDB'      => ['cn=log'],
            'olcAccessLogOps'     => ['writes'],
            'olcAccessLogSuccess' => ['TRUE'],
            'olcAccessLogPurge'   => ['07+00:00 01+00:00'],
          }
        ) }
        it { should contain_openldap('olcOverlay={2}auditlog,olcDatabase={3}hdb,cn=config').with_attributes(
          {
            'objectClass'     => [
              'olcOverlayConfig',
              'olcAuditlogConfig',
            ],
            'olcOverlay'      => ['{2}auditlog'],
            'olcAuditlogFile' => ['/tmp/auditlog.ldif'],
          }
        ) }
        it { should contain_openldap('olcOverlay={3}smbk5pwd,olcDatabase={3}hdb,cn=config').with_attributes(
          {
            'objectClass'           => [
              'olcOverlayConfig',
              'olcSmbK5PwdConfig',
            ],
            'olcOverlay'            => ['{3}smbk5pwd'],
            'olcSmbK5PwdEnable'     => ['samba'],
            'olcSmbK5PwdMustChange' => ['2592000'],
          }
        ) }
        it { should contain_openldap('olcOverlay={4}unique,olcDatabase={3}hdb,cn=config').with_attributes(
          {
            'objectClass'  => [
              'olcOverlayConfig',
              'olcUniqueConfig',
            ],
            'olcOverlay'   => ['{4}unique'],
            'olcUniqueURI' => ['strict ignore ldap:///dc=example,dc=com?uidNumber?sub'],
          }
        ) }
        it { should contain_openldap('olcOverlay={5}ppolicy,olcDatabase={3}hdb,cn=config').with_attributes(
          {
            'objectClass'              => [
              'olcOverlayConfig',
              'olcPPolicyConfig',
            ],
            'olcOverlay'               => ['{5}ppolicy'],
            'olcPPolicyDefault'        => ['cn=passwordDefault,dc=example,dc=com'],
            'olcPPolicyHashCleartext'  => ['TRUE'],
            'olcPPolicyUseLockout'     => ['FALSE'],
            'olcPPolicyForwardUpdates' => ['TRUE'],
          }
        ) }
        it { should contain_openldap('olcOverlay={6}memberof,olcDatabase={3}hdb,cn=config').with_attributes(
          {
            'objectClass' => ['olcOverlayConfig'],
            'olcOverlay'  => ['{6}memberof'],
          }
        ) }
        it { should contain_openldap('olcOverlay={7}refint,olcDatabase={3}hdb,cn=config').with_attributes(
          {
            'objectClass'         => [
              'olcOverlayConfig',
              'olcRefintConfig',
            ],
            'olcOverlay'          => ['{7}refint'],
            'olcRefintAttributes' => ['manager'],
            'olcRefintNothing'    => ['cn=empty,dc=example,dc=com'],
          }
        ) }

        case facts[:osfamily]
        when 'Debian'
          it { should contain_exec('find /etc/ldap/slapd.d') }
          it { should contain_file('/etc/default/slapd') }
          it { should contain_file('/etc/ldap/slapd.d') }
          it { should contain_file('/var/cache/debconf/slapd.preseed') }
          it { should contain_file('/var/lib/ldap') }
          it { should contain_file('/var/lib/ldap/data') }
          it { should contain_file('/var/lib/ldap/log') }
          it { should contain_group('openldap') }
          it { should contain_openldap('cn=config').with_attributes(
            {
              'objectClass'                => ['olcGlobal'],
              'cn'                         => ['config'],
              'olcArgsFile'                => ['/var/run/slapd/slapd.args'],
              'olcAuthzPolicy'             => ['none'],
              'olcLocalSSF'                => ['256'],
              'olcLogLevel'                => ['128 filter 1'],
              'olcPidFile'                 => ['/var/run/slapd/slapd.pid'],
              'olcSecurity'                => ['ssf=256 simple_bind=128'],
              'olcTLSCACertificateFile'    => ['/tmp/cacert.pem'],
              'olcTLSCACertificatePath'    => ['/tmp/certs'],
              'olcTLSCertificateFile'      => ['/tmp/cert.pem'],
              'olcTLSCertificateKeyFile'   => ['/tmp/key.pem'],
              'olcTLSCipherSuite'          => ['HIGH:MEDIUM:+SSLv2'],
              'olcTLSDHParamFile'          => ['/tmp/dhparam.pem'],
              'olcTLSProtocolMin'          => ['3.2'],
              'olcPasswordCryptSaltFormat' => ['%.2s'],
            }
          ) }
          it { should contain_openldap('cn=module{0},cn=config').with_attributes(
            {
              'objectClass'   => ['olcModuleList'],
              'cn'            => ['module{0}'],
              'olcModuleLoad' => [
                '{0}back_monitor.la',
                '{1}back_hdb.la',
                '{2}back_ldap.la',
                '{3}syncprov.la',
                '{4}accesslog.la',
                '{5}auditlog.la',
                '{6}smbk5pwd.la',
                '{7}unique.la',
                '{8}ppolicy.la',
                '{9}memberof.la',
                '{10}refint.la',
                '{11}pw-sha2.la',
              ],
            }
          ) }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'       => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'         => ['{0}to * by dn.exact="cn=replica,dc=example,dc=com" read'],
              'olcDatabase'       => ['{2}hdb'],
              'olcDbCacheSize'    => ['1000'],
              'olcDbCheckpoint'   => ['100 10'],
              'olcDbConfig'       => [
                '{0}set_cachesize 0 2097152 0',
                '{1}set_lk_max_objects 1500',
                '{2}set_lk_max_locks 1500',
                '{3}set_lk_max_lockers 1500',
              ],
              'olcDbDirectory'    => ['/var/lib/ldap/log'],
              'olcDbDNcacheSize'  => ['100'],
              'olcDbIDLcacheSize' => ['300'],
              'olcDbIndex'        => ['entryCSN,objectClass,reqEnd,reqResult,reqStart eq'],
              'olcLimits'         => ['{0}dn.exact="cn=replica,dc=example,dc=com" size.soft=unlimited size.hard=unlimited time.soft=unlimited time.hard=unlimited'],
              'olcRootDN'         => ['cn=Manager,dc=example,dc=com'],
              'olcSuffix'         => ['cn=log']
            }
          ) }
          it { should contain_openldap('olcDatabase={3}hdb,cn=config').with_attributes(
            {
              'objectClass'       => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'         => [
                '{0}to * by dn.exact="cn=replica,dc=example,dc=com" read by * break',
                '{1}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage',
              ],
              'olcDatabase'       => ['{3}hdb'],
              'olcDbCacheSize'    => ['1000'],
              'olcDbCheckpoint'   => ['100 10'],
              'olcDbConfig'       => [
                '{0}set_cachesize 0 2097152 0',
                '{1}set_lk_max_objects 1500',
                '{2}set_lk_max_locks 1500',
                '{3}set_lk_max_lockers 1500',
              ],
              'olcDbDirectory'    => ['/var/lib/ldap/data'],
              'olcDbDNcacheSize'  => ['100'],
              'olcDbIDLcacheSize' => ['300'],
              'olcDbIndex'        => [
                'objectClass eq,pres',
                'entryCSN,entryUUID eq',
              ],
              'olcLimits'         => [
                '{0}dn.exact="cn=replica,dc=example,dc=com" size.soft=unlimited size.hard=unlimited time.soft=unlimited time.hard=unlimited',
                '{1}users size=unlimited time.soft=0 time.hard=unlimited',
              ],
              'olcRootDN'         => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'         => ['secret'],
              'olcSuffix'         => ['dc=example,dc=com'],
              'olcSyncrepl'       => ['{0}rid=001 provider=ldap://ldap.example.com/ searchbase="dc=example,dc=com"'],
              'olcUpdateRef'      => ['ldap://ldap.example.com/'],
            }
          ) }
          it { should contain_openldap_schema('core').with_ldif('/etc/ldap/schema/core.ldif') }
          it { should contain_openldap_schema('ppolicy').with_ldif('/etc/ldap/schema/ppolicy.ldif') }
          it { should contain_package('slapd') }
          it { should contain_package('slapd-smbk5pwd') }
          it { should contain_service('slapd') }
          it { should contain_user('openldap') }
        when 'RedHat'
          case facts[:operatingsystemmajrelease]
          when '6'
            it { should contain_file('/etc/sysconfig/ldap') }
          else
            it { should contain_file('/etc/sysconfig/slapd') }
          end
          it { should contain_exec('find /etc/openldap/slapd.d') }
          it { should contain_file('/etc/openldap/slapd.d') }
          it { should contain_file('/var/lib/ldap') }
          it { should contain_file('/var/lib/ldap/data') }
          it { should contain_file('/var/lib/ldap/log') }
          it { should contain_group('ldap') }
          it { should contain_openldap('cn=config').with_attributes(
            {
              'objectClass'                => ['olcGlobal'],
              'cn'                         => ['config'],
              'olcArgsFile'                => ['/var/run/openldap/slapd.args'],
              'olcAuthzPolicy'             => ['none'],
              'olcLocalSSF'                => ['256'],
              'olcLogLevel'                => ['128 filter 1'],
              'olcPidFile'                 => ['/var/run/openldap/slapd.pid'],
              'olcSecurity'                => ['ssf=256 simple_bind=128'],
              'olcTLSCACertificateFile'    => ['/tmp/cacert.pem'],
              'olcTLSCACertificatePath'    => ['/tmp/certs'],
              'olcTLSCertificateFile'      => ['/tmp/cert.pem'],
              'olcTLSCertificateKeyFile'   => ['/tmp/key.pem'],
              'olcTLSCipherSuite'          => ['HIGH:MEDIUM:+SSLv2'],
              'olcTLSDHParamFile'          => ['/tmp/dhparam.pem'],
              'olcTLSProtocolMin'          => ['3.2'],
              'olcPasswordCryptSaltFormat' => ['%.2s'],
            }
          ) }
          it { should contain_openldap('cn=module{0},cn=config').with_attributes(
            {
              'objectClass'   => ['olcModuleList'],
              'cn'            => ['module{0}'],
              'olcModuleLoad' => [
                '{0}back_ldap.la',
                '{1}syncprov.la',
                '{2}accesslog.la',
                '{3}auditlog.la',
                '{4}smbk5pwd.la',
                '{5}unique.la',
                '{6}ppolicy.la',
                '{7}memberof.la',
                '{8}refint.la',
                '{9}pw-sha2.la',
              ],
            }
          ) }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'       => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'         => ['{0}to * by dn.exact="cn=replica,dc=example,dc=com" read'],
              'olcDatabase'       => ['{2}hdb'],
              'olcDbCacheSize'    => ['1000'],
              'olcDbCheckpoint'   => ['100 10'],
              'olcDbConfig'       => [
                '{0}set_cachesize 0 2097152 0',
                '{1}set_lk_max_objects 1500',
                '{2}set_lk_max_locks 1500',
                '{3}set_lk_max_lockers 1500',
              ],
              'olcDbDirectory'    => ['/var/lib/ldap/log'],
              'olcDbDNcacheSize'  => ['100'],
              'olcDbIDLcacheSize' => ['300'],
              'olcDbIndex'        => ['entryCSN,objectClass,reqEnd,reqResult,reqStart eq'],
              'olcLimits'         => ['{0}dn.exact="cn=replica,dc=example,dc=com" size.soft=unlimited size.hard=unlimited time.soft=unlimited time.hard=unlimited'],
              'olcRootDN'         => ['cn=Manager,dc=example,dc=com'],
              'olcSuffix'         => ['cn=log']
            }
          ) }
          it { should contain_openldap('olcDatabase={3}hdb,cn=config').with_attributes(
            {
              'objectClass'       => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'         => [
                '{0}to * by dn.exact="cn=replica,dc=example,dc=com" read by * break',
                '{1}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage',
              ],
              'olcDatabase'       => ['{3}hdb'],
              'olcDbCacheSize'    => ['1000'],
              'olcDbCheckpoint'   => ['100 10'],
              'olcDbConfig'       => [
                '{0}set_cachesize 0 2097152 0',
                '{1}set_lk_max_objects 1500',
                '{2}set_lk_max_locks 1500',
                '{3}set_lk_max_lockers 1500',
              ],
              'olcDbDirectory'    => ['/var/lib/ldap/data'],
              'olcDbDNcacheSize'  => ['100'],
              'olcDbIDLcacheSize' => ['300'],
              'olcDbIndex'        => [
                'objectClass eq,pres',
                'entryCSN,entryUUID eq',
              ],
              'olcLimits'         => [
                '{0}dn.exact="cn=replica,dc=example,dc=com" size.soft=unlimited size.hard=unlimited time.soft=unlimited time.hard=unlimited',
                '{1}users size=unlimited time.soft=0 time.hard=unlimited',
              ],
              'olcRootDN'         => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'         => ['secret'],
              'olcSuffix'         => ['dc=example,dc=com'],
              'olcSyncrepl'       => ['{0}rid=001 provider=ldap://ldap.example.com/ searchbase="dc=example,dc=com"'],
              'olcUpdateRef'      => ['ldap://ldap.example.com/'],
            }
          ) }
          it { should contain_openldap_schema('core').with_ldif('/etc/openldap/schema/core.ldif') }
          it { should contain_openldap_schema('ppolicy').with_ldif('/etc/openldap/schema/ppolicy.ldif') }
          it { should contain_package('openldap-servers') }
          it { should contain_service('slapd') }
          it { should contain_user('ldap') }
        when 'OpenBSD'
          it { should contain_exec('find /etc/openldap/slapd.d') }
          it { should contain_file('/etc/openldap/schema/corba.ldif') }
          it { should contain_file('/etc/openldap/schema/core.ldif') }
          it { should contain_file('/etc/openldap/schema/cosine.ldif') }
          it { should contain_file('/etc/openldap/schema/dyngroup.ldif') }
          it { should contain_file('/etc/openldap/schema/inetorgperson.ldif') }
          it { should contain_file('/etc/openldap/schema/java.ldif') }
          it { should contain_file('/etc/openldap/schema/misc.ldif') }
          it { should contain_file('/etc/openldap/schema/nis.ldif') }
          it { should contain_file('/etc/openldap/schema/openldap.ldif') }
          it { should contain_file('/etc/openldap/schema/ppolicy.ldif') }
          it { should contain_file('/etc/openldap/slapd.d') }
          it { should contain_file('/var/openldap-data') }
          it { should contain_file('/var/openldap-data/data') }
          it { should contain_file('/var/openldap-data/log') }
          it { should have_group_resource_count(0) }
          it { should contain_openldap('cn=config').with_attributes(
            {
              'objectClass'                => ['olcGlobal'],
              'cn'                         => ['config'],
              'olcArgsFile'                => ['/var/run/openldap/slapd.args'],
              'olcAuthzPolicy'             => ['none'],
              'olcLocalSSF'                => ['256'],
              'olcLogLevel'                => ['128 filter 1'],
              'olcPidFile'                 => ['/var/run/openldap/slapd.pid'],
              'olcSecurity'                => ['ssf=256 simple_bind=128'],
              'olcTLSCACertificateFile'    => ['/tmp/cacert.pem'],
              'olcTLSCACertificatePath'    => ['/tmp/certs'],
              'olcTLSCertificateFile'      => ['/tmp/cert.pem'],
              'olcTLSCertificateKeyFile'   => ['/tmp/key.pem'],
              'olcTLSCipherSuite'          => ['HIGH:MEDIUM:+SSLv2'],
              'olcTLSDHParamFile'          => ['/tmp/dhparam.pem'],
              'olcTLSProtocolMin'          => ['3.2'],
              'olcPasswordCryptSaltFormat' => ['%.2s'],
            }
          ) }
          it { should_not contain_openldap('cn=module{0},cn=config') }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'       => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'         => ['{0}to * by dn.exact="cn=replica,dc=example,dc=com" read'],
              'olcDatabase'       => ['{2}hdb'],
              'olcDbCacheSize'    => ['1000'],
              'olcDbCheckpoint'   => ['100 10'],
              'olcDbConfig'       => [
                '{0}set_cachesize 0 2097152 0',
                '{1}set_lk_max_objects 1500',
                '{2}set_lk_max_locks 1500',
                '{3}set_lk_max_lockers 1500',
              ],
              'olcDbDirectory'    => ['/var/openldap-data/log'],
              'olcDbDNcacheSize'  => ['100'],
              'olcDbIDLcacheSize' => ['300'],
              'olcDbIndex'        => ['entryCSN,objectClass,reqEnd,reqResult,reqStart eq'],
              'olcLimits'         => ['{0}dn.exact="cn=replica,dc=example,dc=com" size.soft=unlimited size.hard=unlimited time.soft=unlimited time.hard=unlimited'],
              'olcRootDN'         => ['cn=Manager,dc=example,dc=com'],
              'olcSuffix'         => ['cn=log']
            }
          ) }
          it { should contain_openldap('olcDatabase={3}hdb,cn=config').with_attributes(
            {
              'objectClass'       => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'         => [
                '{0}to * by dn.exact="cn=replica,dc=example,dc=com" read by * break',
                '{1}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage',
              ],
              'olcDatabase'       => ['{3}hdb'],
              'olcDbCacheSize'    => ['1000'],
              'olcDbCheckpoint'   => ['100 10'],
              'olcDbConfig'       => [
                '{0}set_cachesize 0 2097152 0',
                '{1}set_lk_max_objects 1500',
                '{2}set_lk_max_locks 1500',
                '{3}set_lk_max_lockers 1500',
              ],
              'olcDbDirectory'    => ['/var/openldap-data/data'],
              'olcDbDNcacheSize'  => ['100'],
              'olcDbIDLcacheSize' => ['300'],
              'olcDbIndex'        => [
                'objectClass eq,pres',
                'entryCSN,entryUUID eq',
              ],
              'olcLimits'         => [
                '{0}dn.exact="cn=replica,dc=example,dc=com" size.soft=unlimited size.hard=unlimited time.soft=unlimited time.hard=unlimited',
                '{1}users size=unlimited time.soft=0 time.hard=unlimited',
              ],
              'olcRootDN'         => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'         => ['secret'],
              'olcSuffix'         => ['dc=example,dc=com'],
              'olcSyncrepl'       => ['{0}rid=001 provider=ldap://ldap.example.com/ searchbase="dc=example,dc=com"'],
              'olcUpdateRef'      => ['ldap://ldap.example.com/'],
            }
          ) }
          it { should contain_openldap_schema('core').with_ldif('/etc/openldap/schema/core.ldif') }
          it { should contain_openldap_schema('ppolicy').with_ldif('/etc/openldap/schema/ppolicy.ldif') }
          it { should contain_package('openldap-server') }
          it { should contain_service('slapd') }
          it { should have_user_resource_count(0) }
        end
      end
    end
  end
end
