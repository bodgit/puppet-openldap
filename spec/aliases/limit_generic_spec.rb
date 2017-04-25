require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::limit::generic', type: :class do
    describe 'accepts a generic limit' do
      [
        0,
        100,
        'unlimited',
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile }
        end
      end
    end
    describe 'rejects other values' do
      [
        -1,
        'invalid',
        [0],
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it {is_expected.to compile.and_raise_error(/parameter 'value' /) }
        end
      end
    end
  end
end
