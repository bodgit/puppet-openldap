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
    # FIXME replication
    # producer  = only_host_with_role(hosts, 'producer')
    # consumers = hosts_with_role(hosts, 'consumer')
    # apply_manifest_on(producer, pp, :catch_failures => true)
    # apply_manifest_on(producer, pp, :catch_changes  => true)
    # consumers.each do |consumer|
    #   apply_manifest_on(consumer, pp, :catch_failures => true)
    #   apply_manifest_on(consumer, pp, :catch_changes  => true)
    # end

    pp = <<-EOS
      include ::firewall
      include ::openldap
      include ::openldap::client
      class { '::openldap::server':
        root_dn         => 'cn=Manager,dc=example,dc=com',
        root_password   => 'secret',
        suffix          => 'dc=example,dc=com',
        access          => [
          'to attrs=userPassword by self =xw by anonymous auth',
          'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by users read',
        ],
        auditlog        => true,
        auditlog_file   => '/tmp/auditlog.ldif',
        ldap_interfaces => ['#{default.ip}'],
        local_ssf       => 256,
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
        dn: olcOverlay={0}auditlog,olcDatabase={2}hdb,cn=config
      EOS
    end
  end

  # Import the example database
  describe command('ldapadd -Y EXTERNAL -H ldapi:/// -f /root/example.ldif') do
    its(:exit_status) { should eq 0 }
  end

  describe port(389) do
    it { should be_listening.on(default.ip).with('tcp') }
  end

  # Test that TCP works, binds work, and that no password hashes are disclosed
  describe command("ldapsearch -H ldap://#{default.ip}/ -b dc=example,dc=com -D uid=alice,ou=people,dc=example,dc=com -x -w password") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should_not match /^userPassword/ }
  end

  # Test password change
  describe command("ldappasswd -H ldap://#{default.ip}/ -D uid=alice,ou=people,dc=example,dc=com -x -w password -s secret") do
    its(:exit_status) { should eq 0 }
  end

  # Test password modification made it into the audit log
  describe file('/tmp/auditlog.ldif') do
    it { should be_file }
    its(:content) { should match /^changetype: modify$/ }
    its(:content) { should match /^replace: userPassword$/ }
    its(:content) { should match /^userPassword:: e1NTSEF9/ }
  end
end
