require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::limit', type: :class do
    describe 'accepts a limit' do
      [
        {
          'selector' => 'anonymous',
          'size'     => 0,
        },
        {
          'selector' => 'users',
          'time'     => 'unlimited',
        },
        {
          'selector' => 'dn.self.exact=*',
          'size'     => {
            'soft' => 0,
            'hard' => 'soft',
          },
        },
        {
          'selector' => 'group/groupOfNames/member=*',
          'time'     => {
            'soft' => 0,
            'hard' => 'soft',
          },
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
          'size' => 0,
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
