require 'spec_helper'

describe 'openldap::configuration' do

  let(:title) do
    '/tmp/ldap.conf'
  end

  let(:params) do
    {
      :ensure => 'file',
      :owner  => 0,
      :group  => 0,
      :mode   => '0644',
    }
  end

  let(:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystemmajrelease => 7,
    }
  end

  context 'without openldap class included' do
    it { expect { should compile }.to raise_error(/must include the openldap base class/) }
  end

  context 'with openldap class included' do
    let(:pre_condition) do
      'include ::openldap'
    end

    it do
      should contain_file('/tmp/ldap.conf').with_content(<<-EOS.gsub(/^ +/, ''))
        # !!! Managed by Puppet !!!

      EOS
    end
    it { should contain_openldap__configuration('/tmp/ldap.conf') }
  end
end
