require 'spec_helper_acceptance'

describe 'openldap::server' do
  case fact('osfamily')
  when 'RedHat'
    db_package    = 'libdb-utils'
    db_stat       = 'db_stat'
    package_name  = 'openldap-servers'
    samba_package = 'samba'
    samba_schema  = '/usr/share/doc/samba-4.1.12/LDAP/samba.ldif'
    service_name  = 'slapd'
  when 'Debian'
    db_package    = 'db5.3-util'
    db_stat       = 'db5.3_stat'
    package_name  = 'slapd'
    samba_package = 'samba'
    samba_schema  = '/usr/share/doc/samba/examples/LDAP/samba.ldif'
    service_name  = 'slapd'
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
        root_dn              => 'cn=Manager,dc=example,dc=com',
        root_password        => 'secret',
        suffix               => 'dc=example,dc=com',
        access               => [
          'to attrs=userPassword by self =xw by anonymous auth',
          'to attrs=sambaLMPassword,sambaNTPassword by self =w',
          'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by users read',
        ],
        auditlog             => true,
        auditlog_file        => '/tmp/auditlog.ldif',
        data_cachesize       => 100,
        data_checkpoint      => '1 1',
        data_db_config       => [
          'set_cachesize 0 2097152 0',
          'set_lk_max_objects 1500',
          'set_lk_max_locks 1500',
          'set_lk_max_lockers 1500',
        ],
        data_dn_cachesize    => 100,
        data_index_cachesize => 300,
        ldap_interfaces      => ['#{default.ip}'],
        local_ssf            => 256,
        smbk5pwd             => true,
        smbk5pwd_backends    => ['samba'],
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
      package { '#{samba_package}':
        ensure => present,
      }
      ::openldap::server::schema { 'samba':
        ldif     => '#{samba_schema}',
        position => 4,
      }
      package { '#{db_package}':
        ensure => present,
      }
      case $::osfamily {
        'Debian': {
          service { 'apparmor':
            ensure     => running,
            enable     => true,
            hasstatus  => true,
            hasrestart => true,
            before     => Class['::openldap::server'],
          }
          file { '/etc/apparmor.d/local/usr.sbin.slapd':
            ensure  => file,
            owner   => 0,
            group   => 0,
            mode    => '0600',
            content => "/tmp/* kw,\n",
            notify  => Service['apparmor'],
          }
          exec { 'gzip -d #{samba_schema}.gz':
            path    => ['/bin', '/usr/bin'],
            creates => '#{samba_schema}',
            require => Package['#{samba_package}'],
            before  => ::Openldap::Server::Schema['samba'],
          }
        }
        'RedHat': {
          Package['#{samba_package}'] -> ::Openldap::Server::Schema['samba']
        }
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes  => true)
  end

  describe package(samba_package) do
    it { should be_installed }
  end

  describe file(samba_schema) do
    it { should be_file }
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
        dn: cn={4}samba,cn=schema,cn=config
        dn: olcDatabase={-1}frontend,cn=config
        dn: olcDatabase={0}config,cn=config
        dn: olcDatabase={1}monitor,cn=config
        dn: olcDatabase={2}hdb,cn=config
        dn: olcOverlay={0}auditlog,olcDatabase={2}hdb,cn=config
        dn: olcOverlay={1}smbk5pwd,olcDatabase={2}hdb,cn=config
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
    its(:stdout) { should_not match /^sambaLMPassword/ }
    its(:stdout) { should_not match /^sambaNTPassword/ }
  end

  # Test password change
  describe command("ldappasswd -H ldap://#{default.ip}/ -D uid=alice,ou=people,dc=example,dc=com -x -w password -s secret") do
    its(:exit_status) { should eq 0 }
  end

  # Test that TCP works, binds work, and that no password hashes are disclosed
  describe command("ldapsearch -H ldap://#{default.ip}/ -b dc=example,dc=com -D uid=alice,ou=people,dc=example,dc=com -x -w secret") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should_not match /^userPassword/ }
    its(:stdout) { should_not match /^sambaLMPassword/ }
    its(:stdout) { should_not match /^sambaNTPassword/ }
  end

  # Test password modification made it into the audit log including the
  # associated changes of the Samba hashes via the smbk5pwd overlay
  describe file('/tmp/auditlog.ldif') do
    it { should be_file }
    its(:content) { should match /^changetype: modify$/ }
    its(:content) { should match /^replace: userPassword$/ }
    its(:content) { should match /^userPassword:: e1NTSEF9/ }
    its(:content) { should match /^replace: sambaLMPassword$/ }
    its(:content) { should match /^sambaLMPassword: / }
    its(:content) { should match /^replace: sambaNTPassword$/ }
    its(:content) { should match /^sambaNTPassword: / }
  end

  describe file('/var/lib/ldap/data/DB_CONFIG') do
    it { should be_file }
    its(:content) { should eq <<-EOS.gsub(/^ +/, '') }
      set_cachesize 0 2097152 0
      set_lk_max_objects 1500
      set_lk_max_locks 1500
      set_lk_max_lockers 1500
    EOS
  end

  describe package(db_package) do
    it { should be_installed }
  end

  describe command("#{db_stat} -m -h /var/lib/ldap/data") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^2MB 520KB\s+Total cache size$/ }
    its(:stdout) { should match /^1\s+Number of caches$/ }
    its(:stdout) { should match /^1\s+Maximum number of caches$/ }
  end

  describe command("#{db_stat} -c -h /var/lib/ldap/data") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^1500\s+Maximum number of locks possible$/ }
    its(:stdout) { should match /^1500\s+Maximum number of lockers possible$/ }
    its(:stdout) { should match /^1500\s+Maximum number of lock objects possible$/ }
  end
end
