require 'spec_helper_acceptance'

describe 'openldap' do
  case fact('osfamily')
  when 'RedHat'
    package_name = 'openldap'
    conf_file    = '/etc/openldap/ldap.conf'
  when 'Debian'
    package_name = 'libldap-2.4-2'
    conf_file    = '/etc/ldap/ldap.conf'
  end

  it 'should work with no errors' do

    pp = <<-EOS
      include ::openldap
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes  => true)
  end

  describe package(package_name) do
    it { should be_installed }
  end

  describe file(conf_file) do
    it { should be_file }
  end
end
