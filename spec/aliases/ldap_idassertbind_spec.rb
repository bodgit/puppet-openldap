require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::ldap::idassertbind', type: :class do
    describe 'accepts an LDAP ID Assert bind' do
      [
        {
          'bindmethod'  => 'simple',
          'binddn'      => 'cn=Manager,dc=example,dc=com',
          'credentials' => 'secret',
          'mode'        => 'legacy',
          'flags'       => ['proxy-authz-critical'],
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
          'bindmethod' => 'invalid',
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
