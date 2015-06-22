require 'spec_helper'

describe 'openldap::client' do

  context 'without openldap class included' do
    let(:facts) do
      {
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => 7,
      }
    end

    it { expect { should compile }.to raise_error(/must include the openldap base class/) }
  end

  context 'with openldap class included' do
    let(:pre_condition) do
      'include ::openldap'
    end

    on_supported_os.each do |os, facts|
      context "on #{os}", :compile do
        let(:facts) do
          facts
        end

        it { should contain_anchor('openldap::client::begin') }
        it { should contain_anchor('openldap::client::end') }
        it { should contain_class('openldap::client') }
        it { should contain_class('openldap::client::install') }

        case facts[:osfamily]
        when 'Debian'
          it { should contain_package('ldap-utils') }
        when 'RedHat'
          it { should contain_package('openldap-clients') }
        end
      end
    end
  end
end
