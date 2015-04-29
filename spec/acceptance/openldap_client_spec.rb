require 'spec_helper_acceptance'

describe 'openldap::client' do
  case fact('osfamily')
  when 'RedHat'
    package_name = 'openldap-clients'
  when 'Debian'
    package_name = 'ldap-utils'
  end

  it 'should work with no errors' do

    pp = <<-EOS
      include ::openldap
      include ::openldap::client
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes  => true)
  end

  describe package(package_name) do
    it { should be_installed }
  end
end
