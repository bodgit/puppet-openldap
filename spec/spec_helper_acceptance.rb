require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

hosts.each do |host|
  # Just assume the OpenBSD box has Puppet installed already
  if host['platform'] !~ /^openbsd-/i
    run_puppet_install_helper_on(host)
  end
end

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.before :suite do
    hosts.each do |host|
      puppet_module_install(:source => proj_root, :module_name => 'openldap')
      on host, puppet('module', 'install', 'puppetlabs-stdlib'),   { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-firewall'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'saz-rsyslog'),         { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'bodgit-bodgitlib'),    { :acceptable_exit_codes => [0,1] }
      scp_to(host, File.join(proj_root, 'spec/fixtures/files/example.ldif'), '/root/example.ldif')
      scp_to(host, File.join(proj_root, 'spec/fixtures/files/unique.ldif'),  '/root/unique.ldif')
      scp_to(host, File.join(proj_root, 'spec/fixtures/files/ppolicy.ldif'), '/root/ppolicy.ldif')
      # Install SSL certs and key
      #scp_to(host, File.join(proj_root, 'spec/fixtures/files/ca.crt'), '/etc/pki/tls/ca.crt')
      #scp_to(host, File.join(proj_root, "spec/fixtures/files/#{host}.key"), '/etc/pki/tls/ldap.key')
      #scp_to(host, File.join(proj_root, "spec/fixtures/files/#{host}.crt"), '/etc/pki/tls/ldap.crt')
    end
  end
end
