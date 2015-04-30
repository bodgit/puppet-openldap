require 'spec_helper'

shared_examples_for 'openldap::server' do
  it { should contain_anchor('openldap::server::begin') }
  it { should contain_anchor('openldap::server::end') }
  it { should contain_class('openldap::server') }
  it { should contain_class('openldap::server::config') }
  it { should contain_class('openldap::server::install') }
  it { should contain_class('openldap::server::service') }
  it { should contain_openldap('cn=config') }
  it { should contain_openldap('cn=schema,cn=config') }
  it { should contain_openldap('cn={0}core,cn=schema,cn=config') }
  it { should contain_openldap('olcDatabase={-1}frontend,cn=config') }
  it { should contain_openldap('olcDatabase={0}config,cn=config') }
  it { should contain_openldap('olcDatabase={1}monitor,cn=config') }
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

    context 'as a standalone directory' do
      context 'on RedHat' do
        let(:facts) do
          {
            :osfamily => 'RedHat'
          }
        end

        [6, 7].each do |version|
          context "version #{version}", :compile do
            let(:facts) do
              super().merge(
                {
                  :operatingsystemmajrelease => version
                }
              )
            end

            it_behaves_like 'openldap::server'

            it { should contain_file('/etc/openldap/slapd.d') }
            it { should contain_file('/etc/sysconfig/slapd') }
            it { should contain_file('/var/lib/ldap') }
            it { should contain_file('/var/lib/ldap/data') }
            it { should contain_group('ldap') }
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'          => ['module{0}'],
                'objectClass' => ['olcModuleList'],
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
            it { should contain_openldap__server__schema('core').with_ldif('/etc/openldap/schema/core.ldif') }
            it { should contain_package('openldap-servers') }
            it { should contain_service('slapd') }
            it { should contain_user('ldap') }
          end
        end
      end

      context 'on Ubuntu' do
        let(:facts) do
          {
            :osfamily        => 'Debian',
            :operatingsystem => 'Ubuntu',
            :lsbdistid       => 'Ubuntu'
          }
        end

        ['precise', 'trusty'].each do |codename|
          context "#{codename}", :compile do
            let(:facts) do
              super().merge(
                {
                  :lsbdistcodename => codename
                }
              )
            end

            it_behaves_like 'openldap::server'

            it { should contain_file('/etc/default/slapd') }
            it { should contain_file('/etc/ldap/slapd.d') }
            it { should contain_file('/var/cache/debconf/slapd.preseed') }
            it { should contain_file('/var/lib/ldap') }
            it { should contain_file('/var/lib/ldap/data') }
            it { should contain_group('openldap') }
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
            it { should contain_openldap__server__schema('core').with_ldif('/etc/ldap/schema/core.ldif') }
            it { should contain_package('slapd') }
            it { should contain_service('slapd') }
            it { should contain_user('openldap') }
          end
        end
      end

      context 'on Debian' do
        let(:facts) do
          {
            :osfamily        => 'Debian',
            :operatingsystem => 'Debian',
            :lsbdistid       => 'Debian'
          }
        end

        ['squeeze', 'wheezy'].each do |codename|
          context "#{codename}", :compile do
            let(:facts) do
              super().merge(
                {
                  :lsbdistcodename => codename
                }
              )
            end

            it_behaves_like 'openldap::server'

            it { should contain_file('/etc/default/slapd') }
            it { should contain_file('/etc/ldap/slapd.d') }
            it { should contain_file('/var/cache/debconf/slapd.preseed') }
            it { should contain_file('/var/lib/ldap') }
            it { should contain_file('/var/lib/ldap/data') }
            it { should contain_group('openldap') }
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
            it { should contain_openldap__server__schema('core').with_ldif('/etc/ldap/schema/core.ldif') }
            it { should contain_package('slapd') }
            it { should contain_service('slapd') }
            it { should contain_user('openldap') }
          end
        end
      end
    end

    context 'with syncrepl enabled' do
      let(:params) do
        super().merge(
          {
            :syncprov   => true,
            :replica_dn => 'cn=replicator,dc=example,dc=com',
          }
        )
      end

      context 'on RedHat' do
        let(:facts) do
          {
            :osfamily => 'RedHat'
          }
        end

        [6, 7].each do |version|
          context "version #{version}", :compile do
            let(:facts) do
              super().merge(
                {
                  :operatingsystemmajrelease => version
                }
              )
            end

            it_behaves_like 'openldap::server'

            it { should contain_file('/etc/openldap/slapd.d') }
            it { should contain_file('/etc/sysconfig/slapd') }
            it { should contain_file('/var/lib/ldap') }
            it { should contain_file('/var/lib/ldap/data') }
            it { should contain_group('ldap') }
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'            => ['module{0}'],
                'objectClass'   => ['olcModuleList'],
                'olcModuleLoad' => [
                  '{0}syncprov.la',
                ],
              }
            ) }
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
                'olcDbIndex'     => ['entryCSN,entryUUID eq'],
                'olcLimits'      => [
                  '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
                ],
                'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
                'olcRootPW'      => ['secret'],
                'olcSuffix'      => ['dc=example,dc=com'],
              }
            ) }
            it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={2}hdb,cn=config') }
            it { should contain_openldap__server__schema('core').with_ldif('/etc/openldap/schema/core.ldif') }
            it { should contain_package('openldap-servers') }
            it { should contain_service('slapd') }
            it { should contain_user('ldap') }
          end
        end
      end

      context 'on Ubuntu' do
        let(:facts) do
          {
            :osfamily        => 'Debian',
            :operatingsystem => 'Ubuntu',
            :lsbdistid       => 'Ubuntu'
          }
        end

        ['precise', 'trusty'].each do |codename|
          context "#{codename}", :compile do
            let(:facts) do
              super().merge(
                {
                  :lsbdistcodename => codename
                }
              )
            end

            it_behaves_like 'openldap::server'

            it { should contain_file('/etc/default/slapd') }
            it { should contain_file('/etc/ldap/slapd.d') }
            it { should contain_file('/var/cache/debconf/slapd.preseed') }
            it { should contain_file('/var/lib/ldap') }
            it { should contain_file('/var/lib/ldap/data') }
            it { should contain_group('openldap') }
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
                'olcDbIndex'     => ['entryCSN,entryUUID eq'],
                'olcLimits'      => [
                  '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
                ],
                'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
                'olcRootPW'      => ['secret'],
                'olcSuffix'      => ['dc=example,dc=com'],
              }
            ) }
            it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={2}hdb,cn=config') }
            it { should contain_openldap__server__schema('core').with_ldif('/etc/ldap/schema/core.ldif') }
            it { should contain_package('slapd') }
            it { should contain_service('slapd') }
            it { should contain_user('openldap') }
          end
        end
      end

      context 'on Debian' do
        let(:facts) do
          {
            :osfamily        => 'Debian',
            :operatingsystem => 'Debian',
            :lsbdistid       => 'Debian'
          }
        end

        ['squeeze', 'wheezy'].each do |codename|
          context "#{codename}", :compile do
            let(:facts) do
              super().merge(
                {
                  :lsbdistcodename => codename
                }
              )
            end

            it_behaves_like 'openldap::server'

            it { should contain_file('/etc/default/slapd') }
            it { should contain_file('/etc/ldap/slapd.d') }
            it { should contain_file('/var/cache/debconf/slapd.preseed') }
            it { should contain_file('/var/lib/ldap') }
            it { should contain_file('/var/lib/ldap/data') }
            it { should contain_group('openldap') }
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
                'olcDbIndex'     => ['entryCSN,entryUUID eq'],
                'olcLimits'      => [
                  '{0}dn.exact="cn=replicator,dc=example,dc=com" time.soft=unlimited time.hard=unlimited size.soft=unlimited size.hard=unlimited'
                ],
                'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
                'olcRootPW'      => ['secret'],
                'olcSuffix'      => ['dc=example,dc=com'],
              }
            ) }
            it { should contain_openldap('olcOverlay={0}syncprov,olcDatabase={2}hdb,cn=config') }
            it { should contain_openldap__server__schema('core').with_ldif('/etc/ldap/schema/core.ldif') }
            it { should contain_package('slapd') }
            it { should contain_service('slapd') }
            it { should contain_user('openldap') }
          end
        end
      end

      context 'and delta-syncrepl enabled' do
        let(:params) do
          super().merge(
            {
              :accesslog => true,
            }
          )
        end

        context 'on RedHat' do
          let(:facts) do
            {
              :osfamily => 'RedHat'
            }
          end

          [6, 7].each do |version|
            context "version #{version}", :compile do
              let(:facts) do
                super().merge(
                  {
                    :operatingsystemmajrelease => version
                  }
                )
              end

              it_behaves_like 'openldap::server'

              it { should contain_file('/etc/openldap/slapd.d') }
              it { should contain_file('/etc/sysconfig/slapd') }
              it { should contain_file('/var/lib/ldap') }
              it { should contain_file('/var/lib/ldap/data') }
              it { should contain_file('/var/lib/ldap/log') }
              it { should contain_group('ldap') }
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
                    'entryCSN,objectClass,reqEnd,reqResult,reqStart eq',
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
                  'olcDbIndex'     => ['entryCSN,entryUUID eq'],
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
              it { should contain_openldap__server__schema('core').with_ldif('/etc/openldap/schema/core.ldif') }
              it { should contain_package('openldap-servers') }
              it { should contain_service('slapd') }
              it { should contain_user('ldap') }
            end
          end
        end

        context 'on Ubuntu' do
          let(:facts) do
            {
              :osfamily        => 'Debian',
              :operatingsystem => 'Ubuntu',
              :lsbdistid       => 'Ubuntu'
            }
          end

          ['precise', 'trusty'].each do |codename|
            context "#{codename}", :compile do
              let(:facts) do
                super().merge(
                  {
                    :lsbdistcodename => codename
                  }
                )
              end

              it_behaves_like 'openldap::server'

              it { should contain_file('/etc/default/slapd') }
              it { should contain_file('/etc/ldap/slapd.d') }
              it { should contain_file('/var/cache/debconf/slapd.preseed') }
              it { should contain_file('/var/lib/ldap') }
              it { should contain_file('/var/lib/ldap/data') }
              it { should contain_group('openldap') }
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
                    'entryCSN,objectClass,reqEnd,reqResult,reqStart eq',
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
                  'olcDbIndex'     => ['entryCSN,entryUUID eq'],
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
              it { should contain_openldap__server__schema('core').with_ldif('/etc/ldap/schema/core.ldif') }
              it { should contain_package('slapd') }
              it { should contain_service('slapd') }
              it { should contain_user('openldap') }
            end
          end
        end

        context 'on Debian' do
          let(:facts) do
            {
              :osfamily        => 'Debian',
              :operatingsystem => 'Debian',
              :lsbdistid       => 'Debian'
            }
          end

          ['squeeze', 'wheezy'].each do |codename|
            context "#{codename}", :compile do
              let(:facts) do
                super().merge(
                  {
                    :lsbdistcodename => codename
                  }
                )
              end

              it_behaves_like 'openldap::server'

              it { should contain_file('/etc/default/slapd') }
              it { should contain_file('/etc/ldap/slapd.d') }
              it { should contain_file('/var/cache/debconf/slapd.preseed') }
              it { should contain_file('/var/lib/ldap') }
              it { should contain_file('/var/lib/ldap/data') }
              it { should contain_group('openldap') }
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
                    'entryCSN,objectClass,reqEnd,reqResult,reqStart eq',
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
                  'olcDbIndex'     => ['entryCSN,entryUUID eq'],
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
              it { should contain_openldap__server__schema('core').with_ldif('/etc/ldap/schema/core.ldif') }
              it { should contain_package('slapd') }
              it { should contain_service('slapd') }
              it { should contain_user('openldap') }
            end
          end
        end
      end
    end

    context 'as a consumer' do
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

      context 'on RedHat' do
        let(:facts) do
          {
            :osfamily => 'RedHat'
          }
        end

        [6, 7].each do |version|
          context "version #{version}", :compile do
            let(:facts) do
              super().merge(
                {
                  :operatingsystemmajrelease => version
                }
              )
            end

            it_behaves_like 'openldap::server'

            it { should contain_file('/etc/openldap/slapd.d') }
            it { should contain_file('/etc/sysconfig/slapd') }
            it { should contain_file('/var/lib/ldap') }
            it { should contain_file('/var/lib/ldap/data') }
            it { should contain_group('ldap') }
            it { should contain_openldap('cn=module{0},cn=config').with_attributes(
              {
                'cn'          => ['module{0}'],
                'objectClass' => ['olcModuleList'],
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
                'olcDbIndex'     => ['entryCSN,entryUUID eq'],
                'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
                'olcRootPW'      => ['secret'],
                'olcSuffix'      => ['dc=example,dc=com'],
                'olcSyncrepl'    => ['rid=001 provider=ldap://ldap.example.com/'],
                'olcUpdateRef'   => ['ldap://ldap.example.com/'],
              }
            ) }
            it { should contain_openldap__server__schema('core').with_ldif('/etc/openldap/schema/core.ldif') }
            it { should contain_package('openldap-servers') }
            it { should contain_service('slapd') }
            it { should contain_user('ldap') }
          end
        end
      end

      context 'on Ubuntu' do
        let(:facts) do
          {
            :osfamily        => 'Debian',
            :operatingsystem => 'Ubuntu',
            :lsbdistid       => 'Ubuntu'
          }
        end

        ['precise', 'trusty'].each do |codename|
          context "#{codename}", :compile do
            let(:facts) do
              super().merge(
                {
                  :lsbdistcodename => codename
                }
              )
            end

            it_behaves_like 'openldap::server'

            it { should contain_file('/etc/default/slapd') }
            it { should contain_file('/etc/ldap/slapd.d') }
            it { should contain_file('/var/cache/debconf/slapd.preseed') }
            it { should contain_file('/var/lib/ldap') }
            it { should contain_file('/var/lib/ldap/data') }
            it { should contain_group('openldap') }
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
            it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
              {
                'objectClass'    => [
                  'olcDatabaseConfig',
                  'olcHdbConfig',
                ],
                'olcAccess'      => ['{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'],
                'olcDatabase'    => ['{2}hdb'],
                'olcDbDirectory' => ['/var/lib/ldap/data'],
                'olcDbIndex'     => ['entryCSN,entryUUID eq'],
                'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
                'olcRootPW'      => ['secret'],
                'olcSuffix'      => ['dc=example,dc=com'],
                'olcSyncrepl'    => ['rid=001 provider=ldap://ldap.example.com/'],
                'olcUpdateRef'   => ['ldap://ldap.example.com/'],
              }
            ) }
            it { should contain_openldap__server__schema('core').with_ldif('/etc/ldap/schema/core.ldif') }
            it { should contain_package('slapd') }
            it { should contain_service('slapd') }
            it { should contain_user('openldap') }
          end
        end
      end

      context 'on Debian' do
        let(:facts) do
          {
            :osfamily        => 'Debian',
            :operatingsystem => 'Debian',
            :lsbdistid       => 'Debian'
          }
        end

        ['squeeze', 'wheezy'].each do |codename|
          context "#{codename}", :compile do
            let(:facts) do
              super().merge(
                {
                  :lsbdistcodename => codename
                }
              )
            end

            it_behaves_like 'openldap::server'

            it { should contain_file('/etc/default/slapd') }
            it { should contain_file('/etc/ldap/slapd.d') }
            it { should contain_file('/var/cache/debconf/slapd.preseed') }
            it { should contain_file('/var/lib/ldap') }
            it { should contain_file('/var/lib/ldap/data') }
            it { should contain_group('openldap') }
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
            it { should contain_openldap('olcDatabase={2}hdb,cn=config').with_attributes(
              {
                'objectClass'    => [
                  'olcDatabaseConfig',
                  'olcHdbConfig',
                ],
                'olcAccess'      => ['{0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'],
                'olcDatabase'    => ['{2}hdb'],
                'olcDbDirectory' => ['/var/lib/ldap/data'],
                'olcDbIndex'     => ['entryCSN,entryUUID eq'],
                'olcRootDN'      => ['cn=Manager,dc=example,dc=com'],
                'olcRootPW'      => ['secret'],
                'olcSuffix'      => ['dc=example,dc=com'],
                'olcSyncrepl'    => ['rid=001 provider=ldap://ldap.example.com/'],
                'olcUpdateRef'   => ['ldap://ldap.example.com/'],
              }
            ) }
            it { should contain_openldap__server__schema('core').with_ldif('/etc/ldap/schema/core.ldif') }
            it { should contain_package('slapd') }
            it { should contain_service('slapd') }
            it { should contain_user('openldap') }
          end
        end
      end
    end
  end
end
