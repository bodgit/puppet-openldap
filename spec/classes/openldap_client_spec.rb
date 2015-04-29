require 'spec_helper'

shared_examples_for 'openldap::client' do
  it { should contain_anchor('openldap::client::begin') }
  it { should contain_anchor('openldap::client::end') }
  it { should contain_class('openldap::client') }
  it { should contain_class('openldap::client::install') }
end

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

          it_behaves_like 'openldap::client'

          it { should contain_package('openldap-clients') }
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

          it_behaves_like 'openldap::client'

          it { should contain_package('ldap-utils') }
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

          it_behaves_like 'openldap::client'

          it { should contain_package('ldap-utils') }
        end
      end
    end
  end
end
