require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::access::to', type: :class do
    describe 'accepts an ACL to clause' do
      [
        {
          'dn' => '*',
        },
        {
          'attrs' => ['userPassword'],
        },
        {
          'filter' => '(objectClass=*)',
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
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it {is_expected.to compile.and_raise_error(/parameter 'value' /) }
        end
      end
    end
  end
end
