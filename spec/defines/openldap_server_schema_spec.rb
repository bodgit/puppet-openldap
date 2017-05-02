require 'spec_helper'

describe 'openldap::server::schema' do

  let(:title) do
    'cosine'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'without openldap::server class included' do
        it { expect { should compile }.to raise_error(/must include the openldap::server class/) }
      end

      context 'with openldap::server class included', :compile do
        let(:pre_condition) do
          <<-EOF
            include ::openldap
            if $::osfamily != 'OpenBSD' {
              include ::openldap::client
            }
            class { '::openldap::server':
              root_dn       => 'cn=Manager,dc=example,dc=com',
              root_password => 'secret',
              suffix        => 'dc=example,dc=com',
            }
          EOF
        end

        it { should contain_openldap__server__schema('cosine') }

        case facts[:osfamily]
        when 'Debian'
          it { should contain_openldap_schema('cosine').with_ldif('/etc/ldap/schema/cosine.ldif') }
        when 'RedHat'
          it { should contain_openldap_schema('cosine').with_ldif('/etc/openldap/schema/cosine.ldif') }
        end
      end
    end
  end
end
