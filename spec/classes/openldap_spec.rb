require 'spec_helper'

describe 'openldap' do

  context 'on unsupported distributions' do
    let(:facts) do
      {
        :osfamily => 'Unsupported'
      }
    end

    it { expect { should compile }.to raise_error(/not supported on an Unsupported/) }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}", :compile do
      let(:facts) do
        facts
      end

      it { should contain_class('openldap') }
      it { should contain_class('openldap::config') }
      it { should contain_class('openldap::install') }
      it { should contain_class('openldap::params') }

      case facts[:osfamily]
      when 'Debian'
        it { should contain_file('/etc/ldap') }
        it { should contain_file('/etc/ldap/ldap.conf') }
        it { should contain_openldap__configuration('/etc/ldap/ldap.conf') }
        it { should contain_package('libldap-2.4-2') }
      when 'RedHat'
        it { should contain_file('/etc/openldap') }
        it { should contain_file('/etc/openldap/ldap.conf') }
        it { should contain_openldap__configuration('/etc/openldap/ldap.conf') }
        it { should contain_package('openldap') }
      end
    end
  end
end
