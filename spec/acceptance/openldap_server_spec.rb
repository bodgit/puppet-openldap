require 'spec_helper_acceptance'

describe 'openldap::server' do
  case fact('osfamily')
  when 'RedHat'
    package_name = 'openldap-servers'
    service_name = 'slapd'
  when 'Debian'
    package_name = 'slapd'
    service_name = 'slapd'
  end

  it 'should work with no errors' do
    #master = only_host_with_role(hosts, 'master')
    #slave = only_host_with_role(hosts, 'slave')

    #pp = <<-EOS
    #  class { '::openldap::server':
    #    base_dn       => 'dc=example,dc=com',
    #    root_dn       => 'cn=Manager,dc=example,dc=com',
    #    root_password => '{SSHA}Xc4HG4EgGg4Lo/F1e6n+q7N2EHOOmtny',
    #    masters       => [
    #      'ldap://10.255.33.1/',
    #      'ldap://10.255.33.2/',
    #      'ldap://10.255.33.3/',
    #    ],
    #  }
    #EOS

    #masters = hosts_with_role(hosts, 'multimaster')

    #masters.each do |master|
    #  pp = <<-EOS
    #    class { '::openldap::server':
    #      base_dn       => 'dc=example,dc=com',
    #      root_dn       => 'cn=Manager,dc=example,dc=com',
    #      root_password => '{SSHA}Xc4HG4EgGg4Lo/F1e6n+q7N2EHOOmtny',
    #      ldap_interfaces => ['#{master.ip}'],
    #      masters       => [
    #        'ldap://10.255.33.1/',
    #        'ldap://10.255.33.2/',
    #        'ldap://10.255.33.3/',
    #      ],
    #      ssl_cert      => '/etc/pki/tls/ldap.crt',
    #      ssl_ca        => '/etc/pki/tls/ca.crt',
    #      ssl_key       => '/etc/pki/tls/ldap.key',
    #      ssl_protocol  => '3.3',
    #    }
    #  EOS

    #  apply_manifest_on(master, pp, :catch_failures => true)
    #  apply_manifest_on(master, pp, :catch_changes  => true)
    #end

    pp = <<-EOS
      include ::openldap
      include ::openldap::client
      class { '::openldap::server':
        root_dn       => 'cn=Manager,dc=example,dc=com',
        root_password => '{SSHA}Xc4HG4EgGg4Lo/F1e6n+q7N2EHOOmtny',
        suffix        => 'dc=example,dc=com',
      }
      ::openldap::server::schema { 'cosine':
        position => 1,
      }
      ::openldap::server::schema { 'inetorgperson':
        position => 2,
      }
      ::openldap::server::schema { 'nis':
        position => 3,
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes  => true)
  end

  describe package(package_name) do
    it { should be_installed }
  end

  describe service(service_name) do
    it { should be_running }
  end

  describe command('ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | grep ^dn') do
    its(:exit_status) { should eq 0 }
    its(:stdout) do
      should eq <<-EOS.gsub(/^ +/, '')
        dn: cn=config
        dn: cn=module{0},cn=config
        dn: cn=schema,cn=config
        dn: cn={0}core,cn=schema,cn=config
        dn: cn={1}cosine,cn=schema,cn=config
        dn: cn={2}inetorgperson,cn=schema,cn=config
        dn: cn={3}nis,cn=schema,cn=config
        dn: olcDatabase={-1}frontend,cn=config
        dn: olcDatabase={0}config,cn=config
        dn: olcDatabase={1}monitor,cn=config
        dn: olcDatabase={2}hdb,cn=config
      EOS
    end
  end
end
