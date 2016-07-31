require 'spec_helper'

shared_examples_for 'openldap::server' do
  it { should contain_anchor('openldap::server::begin') }
  it { should contain_anchor('openldap::server::end') }
  it { should contain_class('openldap::server') }
  it { should contain_class('openldap::server::config') }
  it { should contain_class('openldap::server::install') }
  it { should contain_class('openldap::server::service') }
  it { should contain_openldap('cn=schema,cn=config') }
  it { should contain_openldap('cn={0}core,cn=schema,cn=config') }
  it { should contain_openldap('olcDatabase={0}config,cn=config').with_attributes(
    {
      'objectClass' => ['olcDatabaseConfig'],
      'olcAccess'   => ['{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by * none'],
      'olcDatabase' => ['{0}config'],
      'olcLimits'   => ['{0}dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'],
    }
  ) }
  it { should contain_openldap('olcDatabase={1}monitor,cn=config') }
end

shared_examples_for 'openldap::server on Debian' do
  it_behaves_like 'openldap::server'

  it { should contain_exec("find /etc/ldap/slapd.d \\( -type f -exec chmod 0600 '{}' ';' \\) -o \\( -type d -exec chmod 0750 '{}' ';' \\)") }
  it { should contain_file('/etc/default/slapd') }
  it { should contain_file('/etc/ldap/slapd.d') }
  it { should contain_file('/var/cache/debconf/slapd.preseed') }
  it { should contain_file('/var/lib/ldap') }
  it { should contain_file('/var/lib/ldap/data') }
  it { should contain_group('openldap') }
  it { should contain_openldap__server__schema('core').with_ldif('/etc/ldap/schema/core.ldif') }
  it { should contain_package('slapd') }
  it { should contain_service('slapd') }
  it { should contain_user('openldap') }
end

shared_examples_for 'openldap::server on RedHat' do
  it_behaves_like 'openldap::server'

  it { should contain_exec("find /etc/openldap/slapd.d \\( -type f -exec chmod 0600 '{}' ';' \\) -o \\( -type d -exec chmod 0750 '{}' ';' \\)") }
  it { should contain_file('/etc/openldap/slapd.d') }
  it { should contain_file('/var/lib/ldap') }
  it { should contain_file('/var/lib/ldap/data') }
  it { should contain_group('ldap') }
  it { should contain_openldap__server__schema('core').with_ldif('/etc/openldap/schema/core.ldif') }
  it { should contain_package('openldap-servers') }
  it { should contain_service('slapd') }
  it { should contain_user('ldap') }
end

describe 'openldap::server' do

  let(:params) do
    {
      'root_dn'       => 'cn=Manager,dc=example,dc=com',
      'root_password' => 'secret',
      'suffix'        => 'dc=example,dc=com',
    }
  end

  context 'without openldap::client class included' do
    let(:facts) do
      {
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => 7,
      }
    end

    it { expect { should compile }.to raise_error(/must include the openldap::client class/) }
  end

  context 'with openldap::client class included' do
    let(:pre_condition) do
      'include ::openldap include ::openldap::client'
    end

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'as a standalone directory', :compile do

          it_behaves_like "openldap::server on #{facts[:osfamily]}"

          it { should contain_openldap('cn=config') }
          it { should contain_openldap('olcDatabase={-1}frontend,cn=config') }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'    => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'      => ['{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'],
              'olcDatabase'    => ['{2}hdb'],
              'olcDbDirectory' => ['/var/lib/ldap/data'],
              'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'      => ['secret'],
              'olcSuffix'      => ['dc=example,dc=com'],
            }
          ) }

          case facts[:osfamily]
          when 'Debian'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}back_monitor.la',
                  '{1}back_hdb.la',
                ],
              }
            ) }
          when 'RedHat'
            case facts[:operatingsystemmajrelease]
            when '6'
              it { should contain_file('/etc/sysconfig/ldap') }
            else
              it { should contain_file('/etc/sysconfig/slapd') }
            end
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'          => ['module{0}'],
                'objectClass' => ['olcModuleList'],
              }
            ) }
          end
        end

        context 'with auditlog enabled', :compile do
          let(:params) do
            super().merge(
              {
                :auditlog      => true,
                :auditlog_file => '/tmp/auditlog.ldif',
                :log_level     => '128 filter 0x1',
                :size_limit    => 500,
                :time_limit    => 'unlimited',
              }
            )
          end

          it_behaves_like "openldap::server on #{facts[:osfamily]}"

          it { should contain_openldap('olcDatabase={-1}frontend,cn=config').with_attributes(
            {
              'objectClass'  => [
                'olcDatabaseConfig',
                'olcFrontendConfig',
              ],
              'olcDatabase'  => ['{-1}frontend'],
              'olcSizeLimit' => ['500'],
              'olcTimeLimit' => ['unlimited'],
            }
          ) }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'    => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'      => ['{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'],
              'olcDatabase'    => ['{2}hdb'],
              'olcDbDirectory' => ['/var/lib/ldap/data'],
              'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'      => ['secret'],
              'olcSuffix'      => ['dc=example,dc=com'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}auditlog,olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'     => [
                'olcOverlayConfig',
                'olcAuditlogConfig',
              ],
              'olcOverlay'      => ['{0}auditlog'],
              'olcAuditlogFile' => ['/tmp/auditlog.ldif'],
            }
          ) }

          case facts[:osfamily]
          when 'Debian'
            it { should contain_openldap('cn=config').with_attributes(
              {
                'cn'          => ['config'],
                'objectClass' => ['olcGlobal'],
                'olcArgsFile' => ['/var/run/slapd/slapd.args'],
                'olcLogLevel' => ['128 filter 0x1'],
                'olcPidFile'  => ['/var/run/slapd/slapd.pid'],
              }
            ) }
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}back_monitor.la',
                  '{1}back_hdb.la',
                  '{2}auditlog.la',
                ],
              }
            ) }
          when 'RedHat'
            it { should contain_openldap('cn=config').with_attributes(
              {
                'cn'          => ['config'],
                'objectClass' => ['olcGlobal'],
                'olcArgsFile' => ['/var/run/openldap/slapd.args'],
                'olcLogLevel' => ['128 filter 0x1'],
                'olcPidFile'  => ['/var/run/openldap/slapd.pid'],
              }
            ) }
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}auditlog.la',
                ],
              }
            ) }
          end
        end

        context 'with smbk5pwd enabled', :compile do
          let(:params) do
            super().merge(
              {
                :smbk5pwd   => true,
                :size_limit => 'unlimited',
                :time_limit => 3600,
              }
            )
          end

          it_behaves_like "openldap::server on #{facts[:osfamily]}"

          it { should contain_openldap('cn=config') }
          it { should contain_openldap('olcDatabase={-1}frontend,cn=config').with_attributes(
            {
              'objectClass'  => [
                'olcDatabaseConfig',
                'olcFrontendConfig',
              ],
              'olcDatabase'  => ['{-1}frontend'],
              'olcSizeLimit' => ['unlimited'],
              'olcTimeLimit' => ['3600'],
            }
          ) }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'    => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'      => ['{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'],
              'olcDatabase'    => ['{2}hdb'],
              'olcDbDirectory' => ['/var/lib/ldap/data'],
              'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'      => ['secret'],
              'olcSuffix'      => ['dc=example,dc=com'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}smbk5pwd,olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'     => [
                'olcOverlayConfig',
                'olcSmbK5PwdConfig',
              ],
              'olcOverlay'      => ['{0}smbk5pwd'],
            }
          ) }

          case facts[:osfamily]
          when 'Debian'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}back_monitor.la',
                  '{1}back_hdb.la',
                  '{2}smbk5pwd.la',
                ],
              }
            ) }
            it { should contain_package('slapd-smbk5pwd').with_before('Openldap[cn=module{0},cn=config]') }
          when 'RedHat'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}smbk5pwd.la',
                ],
              }
            ) }
          end
        end

        context 'with syncrepl enabled', :compile do
          let(:params) do
            super().merge(
              {
                :data_cachesize       => 1500,
                :data_checkpoint      => '1024 10',
                :data_db_config       => [
                  'set_cachesize 0 2097152 0',
                  'set_lk_max_objects 1500',
                  'set_lk_max_locks 1500',
                  'set_lk_max_lockers 1500',
                ],
                :data_dn_cachesize    => 1500,
                :data_index_cachesize => 4500,
                :size_limit           => 'size.soft=10 size.hard=20',
                :syncprov             => true,
                :time_limit           => 'time.soft=10 time.hard=60',
                :replica_dn           => 'cn=replicator,dc=example,dc=com',
              }
            )
          end

          it_behaves_like "openldap::server on #{facts[:osfamily]}"

          it { should contain_openldap('cn=config') }
          it { should contain_openldap('olcDatabase={-1}frontend,cn=config').with_attributes(
            {
              'objectClass'  => [
                'olcDatabaseConfig',
                'olcFrontendConfig',
              ],
              'olcDatabase'  => ['{-1}frontend'],
              'olcSizeLimit' => ['size.soft=10 size.hard=20'],
              'olcTimeLimit' => ['time.soft=10 time.hard=60'],
            }
          ) }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'       => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'         => [
                '{0}to * by dn.exact="cn=replicator,dc=example,dc=com" read by * break',
                '{1}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage',
              ],
              'olcDatabase'       => ['{2}hdb'],
              'olcDbCacheSize'    => ['1500'],
              'olcDbCheckpoint'   => ['1024 10'],
              'olcDbConfig'       => [
                '{0}set_cachesize 0 2097152 0',
                '{1}set_lk_max_objects 1500',
                '{2}set_lk_max_locks 1500',
                '{3}set_lk_max_lockers 1500',
              ],
              'olcDbDirectory'    => ['/var/lib/ldap/data'],
              'olcDbDNcacheSize'  => ['1500'],
              'olcDbIDLcacheSize' => ['4500'],
              'olcDbIndex'        => ['entryCSN eq', 'entryUUID eq'],
              'olcLimits'         => [
                '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
              ],
              'olcRootDN'         => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'         => ['secret'],
              'olcSuffix'         => ['dc=example,dc=com'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={2}hdb,cn=config') }

          case facts[:osfamily]
          when 'Debian'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}back_monitor.la',
                  '{1}back_hdb.la',
                  '{2}syncprov.la',
                ],
              }
            ) }
          when 'RedHat'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}syncprov.la',
                ],
              }
            ) }
          end
        end

        context 'with unique enabled', :compile do
          let(:params) do
            super().merge(
              {
                :unique     => true,
                :unique_uri => [
                  'ldap:///dc=example,dc=com?uidNumber?sub',
                  'ldap:///dc=example,dc=com?homeDirectory?sub',
                ],
              }
            )
          end

          it_behaves_like "openldap::server on #{facts[:osfamily]}"

          it { should contain_openldap('olcDatabase={-1}frontend,cn=config').with_attributes(
            {
              'objectClass'  => [
                'olcDatabaseConfig',
                'olcFrontendConfig',
              ],
              'olcDatabase'  => ['{-1}frontend'],
            }
          ) }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'    => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'      => ['{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'],
              'olcDatabase'    => ['{2}hdb'],
              'olcDbDirectory' => ['/var/lib/ldap/data'],
              'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'      => ['secret'],
              'olcSuffix'      => ['dc=example,dc=com'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}unique,olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'  => [
                'olcOverlayConfig',
                'olcUniqueConfig',
              ],
              'olcOverlay'   => ['{0}unique'],
              'olcUniqueURI' => [
                'ldap:///dc=example,dc=com?uidNumber?sub',
                'ldap:///dc=example,dc=com?homeDirectory?sub',
              ],
            }
          ) }

          case facts[:osfamily]
          when 'Debian'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}back_monitor.la',
                  '{1}back_hdb.la',
                  '{2}unique.la',
                ],
              }
            ) }
          when 'RedHat'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}unique.la',
                ],
              }
            ) }
          end
        end

        context 'with syncrepl and auditlog enabled', :compile do
          let(:params) do
            super().merge(
              {
                :auditlog      => true,
                :auditlog_file => '/tmp/auditlog.ldif',
                :syncprov      => true,
                :replica_dn    => 'cn=replicator,dc=example,dc=com',
              }
            )
          end

          it_behaves_like "openldap::server on #{facts[:osfamily]}"

          it { should contain_openldap('cn=config') }
          it { should contain_openldap('olcDatabase={-1}frontend,cn=config') }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'    => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'      => [
                '{0}to * by dn.exact="cn=replicator,dc=example,dc=com" read by * break',
                '{1}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage',
              ],
              'olcDatabase'    => ['{2}hdb'],
              'olcDbDirectory' => ['/var/lib/ldap/data'],
              'olcDbIndex'     => ['entryCSN eq', 'entryUUID eq'],
              'olcLimits'      => [
                '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
              ],
              'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'      => ['secret'],
              'olcSuffix'      => ['dc=example,dc=com'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={2}hdb,cn=config') }
          it { should contain_openldap('olcOverlay={1}auditlog,olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'     => [
                'olcOverlayConfig',
                'olcAuditlogConfig',
              ],
              'olcOverlay'      => ['{1}auditlog'],
              'olcAuditlogFile' => ['/tmp/auditlog.ldif'],
            }
          ) }

          case facts[:osfamily]
          when 'Debian'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}back_monitor.la',
                  '{1}back_hdb.la',
                  '{2}syncprov.la',
                  '{3}auditlog.la',
                ],
              }
            ) }
          when 'RedHat'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}syncprov.la',
                  '{1}auditlog.la',
                ],
              }
            ) }
          end
        end

        context 'with delta-syncrepl enabled', :compile do
          let(:params) do
            super().merge(
              {
                :syncprov   => true,
                :replica_dn => 'cn=replicator,dc=example,dc=com',
                :accesslog  => true,
              }
            )
          end

          it_behaves_like "openldap::server on #{facts[:osfamily]}"

          it { should contain_file('/var/lib/ldap/log') }
          it { should contain_openldap('cn=config') }
          it { should contain_openldap('olcDatabase={-1}frontend,cn=config') }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'    => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'      => [
                '{0}to * by dn.exact="cn=replicator,dc=example,dc=com" read',
              ],
              'olcDatabase'    => ['{2}hdb'],
              'olcDbDirectory' => ['/var/lib/ldap/log'],
              'olcDbIndex'     => [
                'entryCSN eq', 'objectClass eq', 'reqEnd eq', 'reqResult eq', 'reqStart eq'
              ],
              'olcLimits'      => [
                '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
              ],
              'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
              'olcSuffix'      => ['cn=log'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={2}hdb,cn=config') }
          it { should contain_openldap('olcDatabase={3}hdb,cn=config').with_attributes(
            {
              'objectClass'    => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'      => [
                '{0}to * by dn.exact="cn=replicator,dc=example,dc=com" read by * break',
                '{1}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage',
              ],
              'olcDatabase'    => ['{3}hdb'],
              'olcDbDirectory' => ['/var/lib/ldap/data'],
              'olcDbIndex'     => ['entryCSN eq', 'entryUUID eq'],
              'olcLimits'      => [
                '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
              ],
              'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'      => ['secret'],
              'olcSuffix'      => ['dc=example,dc=com'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={3}hdb,cn=config') }
          it { should contain_openldap('olcOverlay={1}accesslog,olcDatabase={3}hdb,cn=config') }

          case facts[:osfamily]
          when 'Debian'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}back_monitor.la',
                  '{1}back_hdb.la',
                  '{2}syncprov.la',
                  '{3}accesslog.la',
                ],
              }
            ) }
          when 'RedHat'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}syncprov.la',
                  '{1}accesslog.la',
                ],
              }
            ) }
          end
        end

        context 'with delta-syncrepl and auditlog enabled', :compile do
          let(:params) do
            super().merge(
              {
                :auditlog                  => true,
                :auditlog_file             => '/tmp/auditlog.ldif',
                :syncprov                  => true,
                :replica_dn                => 'cn=replicator,dc=example,dc=com',
                :accesslog                 => true,
                :accesslog_cachesize       => 1500,
                :accesslog_checkpoint      => '1024 10',
                :accesslog_db_config       => [
                  'set_cachesize 0 2097152 0',
                  'set_lk_max_objects 1500',
                  'set_lk_max_locks 1500',
                  'set_lk_max_lockers 1500',
                ],
                :accesslog_dn_cachesize    => 1500,
                :accesslog_index_cachesize => 4500,
              }
            )
          end

          it_behaves_like "openldap::server on #{facts[:osfamily]}"

          it { should contain_file('/var/lib/ldap/log') }
          it { should contain_openldap('cn=config') }
          it { should contain_openldap('olcDatabase={-1}frontend,cn=config') }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'       => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'         => [
                '{0}to * by dn.exact="cn=replicator,dc=example,dc=com" read',
              ],
              'olcDatabase'       => ['{2}hdb'],
              'olcDbCacheSize'    => ['1500'],
              'olcDbCheckpoint'   => ['1024 10'],
              'olcDbConfig'       => [
                '{0}set_cachesize 0 2097152 0',
                '{1}set_lk_max_objects 1500',
                '{2}set_lk_max_locks 1500',
                '{3}set_lk_max_lockers 1500',
              ],
              'olcDbDirectory'    => ['/var/lib/ldap/log'],
              'olcDbDNcacheSize'  => ['1500'],
              'olcDbIDLcacheSize' => ['4500'],
              'olcDbIndex'        => [
                'entryCSN eq', 'objectClass eq', 'reqEnd eq', 'reqResult eq', 'reqStart eq'
              ],
              'olcLimits'         => [
                '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
              ],
              'olcRootDN'         => ['cn=Manager,dc=example,dc=com'],
              'olcSuffix'         => ['cn=log'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={2}hdb,cn=config') }
          it { should contain_openldap('olcDatabase={3}hdb,cn=config').with_attributes(
            {
              'objectClass'    => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'      => [
                '{0}to * by dn.exact="cn=replicator,dc=example,dc=com" read by * break',
                '{1}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage',
              ],
              'olcDatabase'    => ['{3}hdb'],
              'olcDbDirectory' => ['/var/lib/ldap/data'],
              'olcDbIndex'     => ['entryCSN eq', 'entryUUID eq'],
              'olcLimits'      => [
                '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
              ],
              'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'      => ['secret'],
              'olcSuffix'      => ['dc=example,dc=com'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={3}hdb,cn=config') }
          it { should contain_openldap('olcOverlay={1}accesslog,olcDatabase={3}hdb,cn=config') }
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

          case facts[:osfamily]
          when 'Debian'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}back_monitor.la',
                  '{1}back_hdb.la',
                  '{2}syncprov.la',
                  '{3}accesslog.la',
                  '{4}auditlog.la',
                ],
              }
            ) }
          when 'RedHat'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}syncprov.la',
                  '{1}accesslog.la',
                  '{2}auditlog.la',
                ],
              }
            ) }
          end
        end

        context 'with delta-syncrepl, auditlog and smbk5pwd enabled', :compile do
          let(:params) do
            super().merge(
              {
                :accesslog                 => true,
                :accesslog_cachesize       => 1500,
                :accesslog_checkpoint      => '1024 10',
                :accesslog_db_config       => [
                  'set_cachesize 0 2097152 0',
                  'set_lk_max_objects 1500',
                  'set_lk_max_locks 1500',
                  'set_lk_max_lockers 1500',
                ],
                :accesslog_dn_cachesize    => 1500,
                :accesslog_index_cachesize => 4500,
                :auditlog                  => true,
                :auditlog_file             => '/tmp/auditlog.ldif',
                :smbk5pwd                  => true,
                :smbk5pwd_backends         => [
                  'samba'
                ],
                :smbk5pwd_must_change      => 2592000,
                :syncprov                  => true,
                :replica_dn                => 'cn=replicator,dc=example,dc=com',
              }
            )
          end

          it_behaves_like "openldap::server on #{facts[:osfamily]}"

          it { should contain_file('/var/lib/ldap/log') }
          it { should contain_openldap('cn=config') }
          it { should contain_openldap('olcDatabase={-1}frontend,cn=config') }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'       => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'         => [
                '{0}to * by dn.exact="cn=replicator,dc=example,dc=com" read',
              ],
              'olcDatabase'       => ['{2}hdb'],
              'olcDbCacheSize'    => ['1500'],
              'olcDbCheckpoint'   => ['1024 10'],
              'olcDbConfig'       => [
                '{0}set_cachesize 0 2097152 0',
                '{1}set_lk_max_objects 1500',
                '{2}set_lk_max_locks 1500',
                '{3}set_lk_max_lockers 1500',
              ],
              'olcDbDirectory'    => ['/var/lib/ldap/log'],
              'olcDbDNcacheSize'  => ['1500'],
              'olcDbIDLcacheSize' => ['4500'],
              'olcDbIndex'        => [
                'entryCSN eq', 'objectClass eq', 'reqEnd eq', 'reqResult eq', 'reqStart eq'
              ],
              'olcLimits'         => [
                '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
              ],
              'olcRootDN'         => ['cn=Manager,dc=example,dc=com'],
              'olcSuffix'         => ['cn=log'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={2}hdb,cn=config') }
          it { should contain_openldap('olcDatabase={3}hdb,cn=config').with_attributes(
            {
              'objectClass'    => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'      => [
                '{0}to * by dn.exact="cn=replicator,dc=example,dc=com" read by * break',
                '{1}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage',
              ],
              'olcDatabase'    => ['{3}hdb'],
              'olcDbDirectory' => ['/var/lib/ldap/data'],
              'olcDbIndex'     => ['entryCSN eq', 'entryUUID eq'],
              'olcLimits'      => [
                '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
              ],
              'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'      => ['secret'],
              'olcSuffix'      => ['dc=example,dc=com'],
            }
          ) }
          it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={3}hdb,cn=config') }
          it { should contain_openldap('olcOverlay={1}accesslog,olcDatabase={3}hdb,cn=config') }
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

          case facts[:osfamily]
          when 'Debian'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}back_monitor.la',
                  '{1}back_hdb.la',
                  '{2}syncprov.la',
                  '{3}accesslog.la',
                  '{4}auditlog.la',
                  '{5}smbk5pwd.la',
                ],
              }
            ) }
            it { should contain_package('slapd-smbk5pwd').with_before('Openldap[cn=module{0},cn=config]') }
          when 'RedHat'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}syncprov.la',
                  '{1}accesslog.la',
                  '{2}auditlog.la',
                  '{3}smbk5pwd.la',
                ],
              }
            ) }
          end
        end

        context 'as a consumer', :compile do
          let(:params) do
            super().merge(
              {
                :syncrepl   => [
                  'rid=001 provider=ldap://ldap.example.com/',
                ],
                :update_ref => [
                  'ldap://ldap.example.com/',
                ],
              }
            )
          end

          it_behaves_like "openldap::server on #{facts[:osfamily]}"

          it { should contain_openldap('cn=config') }
          it { should contain_openldap('olcDatabase={-1}frontend,cn=config') }
          it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
            {
              'objectClass'    => [
                'olcDatabaseConfig',
                'olcHdbConfig',
              ],
              'olcAccess'      => ['{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'],
              'olcDatabase'    => ['{2}hdb'],
              'olcDbDirectory' => ['/var/lib/ldap/data'],
              'olcDbIndex'     => ['entryCSN eq', 'entryUUID eq'],
              'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
              'olcRootPW'      => ['secret'],
              'olcSuffix'      => ['dc=example,dc=com'],
              'olcSyncrepl'    => ['{0}rid=001 provider=ldap://ldap.example.com/'],
              'olcUpdateRef'   => ['{0}ldap://ldap.example.com/'],
            }
          ) }

          case facts[:osfamily]
          when 'Debian'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}back_monitor.la',
                  '{1}back_hdb.la',
                ],
              }
            ) }
          when 'RedHat'
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'          => ['module{0}'],
                'objectClass' => ['olcModuleList'],
              }
            ) }
          end
        end
      end
    end
  end
end
