require 'spec_helper_acceptance'

describe 'openldap::server' do
  case fact('osfamily')
  when 'RedHat'
    data_directory = '/var/lib/ldap'
    db_stat        = 'db_stat'
    package_name   = 'openldap-servers'
    samba_package  = 'samba'
    case fact(:operatingsystemmajrelease)
    when '6'
      db_package   = 'db4-utils'
      samba_schema = '/usr/share/doc/samba-3.6.23/LDAP/samba.ldif'
    when '7'
      db_package   = 'libdb-utils'
      samba_schema = '/usr/share/doc/samba-4.4.4/LDAP/samba.ldif'
    end
    service_name   = 'slapd'
  when 'Debian'
    data_directory = '/var/lib/ldap'
    case fact('operatingsystemmajrelease')
    when '7'
      db_package = 'db5.1-util'
      db_stat    = 'db5.1_stat'
    else
      db_package = 'db5.3-util'
      db_stat    = 'db5.3_stat'
    end
    package_name   = 'slapd'
    samba_package  = 'samba'
    samba_schema   = '/usr/share/doc/samba/examples/LDAP/samba.ldif'
    service_name   = 'slapd'
  when 'OpenBSD'
    data_directory = '/var/openldap-data'
    db_package     = 'db'
    db_stat        = 'db4_stat'
    package_name   = 'openldap-server'
    samba_package  = 'samba-docs'
    samba_schema   = '/usr/local/share/examples/samba/LDAP/samba.ldif'
    service_name   = 'slapd'
  end

  it 'should work with no errors' do
    pp = <<-EOS
      Package {
        source => $::osfamily ? {
          # $::architecture fact has gone missing on facter 3.x package currently installed
          'OpenBSD' => "http://ftp.openbsd.org/pub/OpenBSD/${::operatingsystemrelease}/packages/amd64/",
          default   => undef,
        },
      }

      include ::openldap

      if $::osfamily == 'OpenBSD' {
        file { '/var/log/slapd.log':
          ensure => file,
          owner  => 0,
          group  => 0,
          mode   => '0644',
        }

        file_line { '/var/log/slapd.log':
          ensure  => present,
          path    => '/etc/syslog.conf',
          line    => "local4.*\t/var/log/slapd.log",
          require => File['/var/log/slapd.log'],
          notify  => Service['syslogd'],
        }

        service { 'syslogd':
          ensure => running,
          enable => true,
          before => Class['::openldap::server'],
        }
      } else {
        include ::openldap::client
        include ::firewall

        class { '::rsyslog::client':
          log_remote => false,
          log_local  => true,
          before     => Class['::openldap::server'],
        }

        file { "${::rsyslog::rsyslog_d}/slapd.conf":
          ensure  => file,
          owner   => 0,
          group   => 0,
          mode    => '0644',
          content => "local4.* /var/log/slapd.log\n",
          notify  => Service[$::rsyslog::service_name],
        }
      }

      class { '::openldap::server':
        root_dn                 => 'cn=Manager,dc=example,dc=com',
        root_password           => 'secret',
        suffix                  => 'dc=example,dc=com',
        access                  => [
          [
            {
              'attrs' => ['userPassword'],
            },
            [
              {
                'who'    => ['self'],
                'access' => '=xw',
              },
              {
                'who'    => ['anonymous'],
                'access' => 'auth',
              },
            ],
          ],
          [
            {
              'attrs' => [
                'sambaLMPassword',
                'sambaNTPassword',
              ],
            },
            [
              {
                'who'    => ['self'],
                'access' => '=w',
              },
            ],
          ],
          [
            {
              'dn' => '*',
            },
            [
              {
                'who'    => ['dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"'],
                'access' => 'manage',
              },
              {
                'who'    => ['users'],
                'access' => 'read',
              },
            ],
          ],
        ],
        auditlog                => true,
        auditlog_file           => '/tmp/auditlog.ldif',
        data_cachesize          => 100,
        data_checkpoint         => [1, 1],
        data_db_config          => [
          'set_cachesize 0 2097152 0',
          'set_lk_max_objects 1500',
          'set_lk_max_locks 1500',
          'set_lk_max_lockers 1500',
        ],
        data_dn_cachesize       => 100,
        data_index_cachesize    => 300,
        local_ssf               => 256,
        log_level               => [65535],
        ppolicy                 => true,
        ppolicy_default         => 'cn=passwordDefault,dc=example,dc=com',
        ppolicy_forward_updates => false,
        ppolicy_hash_cleartext  => true,
        ppolicy_use_lockout     => false,
        size_limit              => {
          'soft' => 1,
          'hard' => 'unlimited',
        },
        smbk5pwd                => $::osfamily ? {
          'OpenBSD' => false,
          default   => true,
        },
        smbk5pwd_backends       => ['samba'],
        unique                  => true,
        unique_uri              => [
          {
            'uri' => ['ldap:///dc=example,dc=com?uidNumber?sub'],
          },
        ],
      }

      ::openldap::server::schema { 'cosine':
        ensure => present,
      }
      ::openldap::server::schema { 'inetorgperson':
        ensure  => present,
        require => ::Openldap::Server::Schema['cosine'],
      }
      ::openldap::server::schema { 'nis':
        ensure  => present,
        require => ::Openldap::Server::Schema['inetorgperson'],
      }

      package { '#{samba_package}':
        ensure => present,
      }
      ::openldap::server::schema { 'samba':
        ensure  => present,
        ldif    => '#{samba_schema}',
        require => ::Openldap::Server::Schema['nis'],
      }

      package { '#{db_package}':
        ensure => present,
      }

      case $::osfamily {
        'Debian': {
          case $::operatingsystem {
            'Ubuntu': {
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
            }
          }

          exec { 'gzip -d #{samba_schema}.gz':
            path    => $::path,
            creates => '#{samba_schema}',
            require => Package['#{samba_package}'],
            before  => ::Openldap::Server::Schema['samba'],
          }
        }
        default: {
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

  describe command('ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | grep ^dn'), :unless => fact('osfamily').eql?('OpenBSD') do
    its(:exit_status) { should eq 0 }
    its(:stdout) do
      should eq <<-EOS.gsub(/^ +/, '')
        dn: cn=config
        dn: cn=module{0},cn=config
        dn: cn=schema,cn=config
        dn: cn={0}core,cn=schema,cn=config
        dn: cn={1}ppolicy,cn=schema,cn=config
        dn: cn={2}cosine,cn=schema,cn=config
        dn: cn={3}inetorgperson,cn=schema,cn=config
        dn: cn={4}nis,cn=schema,cn=config
        dn: cn={5}samba,cn=schema,cn=config
        dn: olcDatabase={-1}frontend,cn=config
        dn: olcDatabase={0}config,cn=config
        dn: olcDatabase={1}monitor,cn=config
        dn: olcDatabase={2}hdb,cn=config
        dn: olcOverlay={0}auditlog,olcDatabase={2}hdb,cn=config
        dn: olcOverlay={1}smbk5pwd,olcDatabase={2}hdb,cn=config
        dn: olcOverlay={2}unique,olcDatabase={2}hdb,cn=config
        dn: olcOverlay={3}ppolicy,olcDatabase={2}hdb,cn=config
      EOS
    end
  end

  describe command('ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config | grep ^dn'), :if => fact('osfamily').eql?('OpenBSD') do
    its(:exit_status) { should eq 0 }
    its(:stdout) do
      should eq <<-EOS.gsub(/^ +/, '')
        dn: cn=config
        dn: cn=schema,cn=config
        dn: cn={0}core,cn=schema,cn=config
        dn: cn={1}ppolicy,cn=schema,cn=config
        dn: cn={2}cosine,cn=schema,cn=config
        dn: cn={3}inetorgperson,cn=schema,cn=config
        dn: cn={4}nis,cn=schema,cn=config
        dn: cn={5}samba,cn=schema,cn=config
        dn: olcDatabase={-1}frontend,cn=config
        dn: olcDatabase={0}config,cn=config
        dn: olcDatabase={1}monitor,cn=config
        dn: olcDatabase={2}hdb,cn=config
        dn: olcOverlay={0}auditlog,olcDatabase={2}hdb,cn=config
        dn: olcOverlay={1}unique,olcDatabase={2}hdb,cn=config
        dn: olcOverlay={2}ppolicy,olcDatabase={2}hdb,cn=config
      EOS
    end
  end

  # Import the example database
  describe command('ldapadd -Y EXTERNAL -H ldapi:/// -f /root/example.ldif') do
    its(:exit_status) { should eq 0 }
  end

  describe port(389) do
    it { should be_listening.on('0.0.0.0').with('tcp') }
  end

  # Test that TCP works, binds work, but that the soft size limit is triggered
  describe command("ldapsearch -H ldap://127.0.0.1/ -b dc=example,dc=com -D uid=alice,ou=people,dc=example,dc=com -x -w password") do
    its(:exit_status) { should eq 4 }
    its(:stdout) { should match /^result: 4 Size limit exceeded$/ }
  end

  # Test that the ppolicy overlay can be added into {2}hdb
  describe command("ldapadd -Y EXTERNAL -H ldapi:/// -f /root/ppolicy.ldif") do
    its(:exit_status) { should eq 0 }
  end

  # Test that the ppolicy overlay is enforced with a pw change
  # that is under the char limit
  describe command("ldappasswd -H ldap://127.0.0.1/ -D uid=alice,ou=people,dc=example,dc=com -x -w password -s secret") do
    its(:exit_status) { should eq 1 }
    its(:stdout) { should match /Password fails quality checking policy/ }
  end

  # Test password change that satisfies the ppolicy overlay
  describe command("ldappasswd -H ldap://127.0.0.1/ -D uid=alice,ou=people,dc=example,dc=com -x -w password -s verysecret") do
    its(:exit_status) { should eq 0 }
  end

  # Test that TCP works, binds work, and that no password hashes are disclosed
  describe command("ldapsearch -H ldap://127.0.0.1/ -b dc=example,dc=com -D uid=alice,ou=people,dc=example,dc=com -x -w verysecret -z max") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should_not match /^userPassword/ }
    its(:stdout) { should_not match /^sambaLMPassword/ }
    its(:stdout) { should_not match /^sambaNTPassword/ }
  end

  # Test that the uniqueness of uidNumber is enforced
  describe command("ldapadd -Y EXTERNAL -H ldapi:/// -f /root/unique.ldif") do
    its(:exit_status) { should eq 19 }
    its(:stderr) { should match /some attributes not unique/ }
  end

  # Test password modification made it into the audit log including the
  # associated changes of the Samba hashes via the smbk5pwd overlay
  describe file('/tmp/auditlog.ldif'), :unless => fact('osfamily').eql?('OpenBSD') do
    it { should be_file }
    its(:content) { should match /^changetype: modify$/ }
    its(:content) { should match /^replace: userPassword$/ }
    its(:content) { should match /^userPassword:: e1NTSEF9/ }
    its(:content) { should match /^replace: sambaLMPassword$/ }
    its(:content) { should match /^sambaLMPassword: / }
    its(:content) { should match /^replace: sambaNTPassword$/ }
    its(:content) { should match /^sambaNTPassword: / }
  end

  # Test password modification made it into the audit log
  describe file('/tmp/auditlog.ldif'), :if => fact('osfamily').eql?('OpenBSD') do
    it { should be_file }
    its(:content) { should match /^changetype: modify$/ }
    its(:content) { should match /^replace: userPassword$/ }
    its(:content) { should match /^userPassword:: e1NTSEF9/ }
  end

  describe file("#{data_directory}/data/DB_CONFIG") do
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

  describe command("#{db_stat} -m -h #{data_directory}/data") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^2MB (520KB|514KB \d+B)\s+Total cache size$/ }
    its(:stdout) { should match /^1\s+Number of caches$/ }
    its(:stdout) { should match /^1\s+Maximum number of caches$/ }
  end

  describe command("#{db_stat} -c -h #{data_directory}/data") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match /^1500\s+Maximum number of locks possible$/ }
    its(:stdout) { should match /^1500\s+Maximum number of lockers possible$/ }
    its(:stdout) { should match /^1500\s+Maximum number of lock objects possible$/ }
  end

  describe file('/var/log/slapd.log') do
    it { should be_file }
    its(:size) { should > 0 }
  end
end
