require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::syncrepl', type: :class do
    describe 'accepts a syncrepl specification' do
      [
        {
          'rid'            => 1,
          'provider'       => 'ldap://ldap.example.com',
          'searchbase'     => 'dc=example,dc=com',
          'type'           => 'refreshAndPersist',
          'bindmethod'     => 'simple',
          'binddn'         => 'cn=Manager,dc=example,dc=com',
          'credentials'    => 'secret',
          'logbase'        => 'cn=log',
          'logfilter'      => '(&(objectClass=auditWriteObject)(reqResult=0))',
          'schemachecking' => true,
          'syncdata'       => 'accesslog',
          'retry'          => [
            [60, '+']
          ],
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
          'rid'        => 1000,
          'provider'   => 'ldap://ldap.example.com',
          'searchbase' => 'dc=example,dc=com',
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
