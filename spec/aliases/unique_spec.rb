require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::unique', type: :class do
    describe 'accepts a unique specification' do
      [
        {
          'uri' => ['ldap:///??sub'],
        },
        {
          'strict' => true,
          'uri'    => ['ldap:///??sub'],
        },
        {
          'ignore' => true,
          'uri'    => ['ldap:///??sub'],
        },
        {
          'strict' => true,
          'ignore' => true,
          'uri'    => [
            'ldap:///??sub',
            'ldap:///?cn?sub?(sn=e*)',
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
          'uri' => [],
        },
        {
          'invalid' => true,
          'uri'     => ['ldap:///??sub'],
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
