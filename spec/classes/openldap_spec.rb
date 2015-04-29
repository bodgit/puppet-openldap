require 'spec_helper'

shared_examples_for 'openldap' do
  it { should contain_anchor('openldap::begin') }
  it { should contain_anchor('openldap::end') }
  it { should contain_class('openldap') }
  it { should contain_class('openldap::config') }
  it { should contain_class('openldap::install') }
  it { should contain_class('openldap::params') }
end

describe 'openldap' do

  context 'on unsupported distributions' do
    let(:facts) do
      {
        :osfamily => 'Unsupported'
      }
    end

    it { expect { should compile }.to raise_error(/not supported on an Unsupported/) }
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

        it_behaves_like 'openldap'

        it { should contain_file('/etc/openldap') }
        it { should contain_file('/etc/openldap/ldap.conf') }
        it { should contain_openldap__configuration('/etc/openldap/ldap.conf') }
        it { should contain_package('openldap') }
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

        it_behaves_like 'openldap'

        it { should contain_file('/etc/ldap') }
        it { should contain_file('/etc/ldap/ldap.conf') }
        it { should contain_openldap__configuration('/etc/ldap/ldap.conf') }
        it { should contain_package('libldap-2.4-2') }
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

        it_behaves_like 'openldap'

        it { should contain_file('/etc/ldap') }
        it { should contain_file('/etc/ldap/ldap.conf') }
        it { should contain_openldap__configuration('/etc/ldap/ldap.conf') }
        it { should contain_package('libldap-2.4-2') }
      end
    end
  end
end
