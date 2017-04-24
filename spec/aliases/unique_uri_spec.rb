require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::unique::uri', type: :class do
    describe 'accepts a unique URI' do
      [
        'ldap:///??sub',
        'ldap:///ou=people,dc=example,dc=com?uidNumber?sub',
        'ldap:///?cn?sub?(sn=e*)'
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
        'ldap://ldap.example.com/',
        'ldap:///',
        'ldap:///?',
        'ldap:///??',
        ['ldap:///??sub'],
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it {is_expected.to compile.and_raise_error(/parameter 'value' /) }
        end
      end
    end
  end
end
