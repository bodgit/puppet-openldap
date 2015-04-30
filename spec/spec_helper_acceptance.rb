require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

hosts.each do |host|
  install_puppet
end

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.before :suite do
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'openldap')
      on host, puppet('module', 'install', 'puppetlabs-stdlib'),   { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-firewall'), { :acceptable_exit_codes => [0,1] }
      scp_to(host, File.join(proj_root, 'spec/fixtures/files/example.ldif'), '/root/example.ldif')
      # Install SSL certs and key
      #scp_to(host, File.join(proj_root, 'spec/fixtures/files/ca.crt'), '/etc/pki/tls/ca.crt')
      #scp_to(host, File.join(proj_root, "spec/fixtures/files/#{host}.key"), '/etc/pki/tls/ldap.key')
      #scp_to(host, File.join(proj_root, "spec/fixtures/files/#{host}.crt"), '/etc/pki/tls/ldap.crt')
    end
  end
end
