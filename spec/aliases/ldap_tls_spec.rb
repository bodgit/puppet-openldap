require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::ldap::tls', type: :class do
    describe 'accepts an LDAP TLS' do
      [
        {
          'mode'            => 'ldaps',
          'tls_cert'        => '/tmp/cert.pem',
          'tls_key'         => '/tmp/key.pem',
          'tls_cacert'      => '/tmp/cacert.pem',
          'tls_cacertdir'   => '/tmp',
          'tls_reqcert'     => 'never',
          'tls_ciphersuite' => 'HIGH:MEDIUM:+SSLv2',
          'tls_crlcheck'    => 'none',
        },
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile }
        end
      end
    end
    describe 'rejects other values' do
      [
        'invalid',
        123,
        {
          'mode' => 'invalid',
        },
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it {is_expected.to compile.and_raise_error(/parameter 'value' /) }
        end
      end
    end
  end
end
