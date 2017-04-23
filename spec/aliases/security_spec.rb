require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::security', type: :class do
    describe 'accepts a security spec' do
      [
        {
          'ssf'              => 0,
          'transport'        => 0,
          'tls'              => 0,
          'sasl'             => 0,
          'update_ssf'       => 0,
          'update_transport' => 0,
          'update_tls'       => 0,
          'update_sasl'      => 0,
          'simple_bind'      => 0,
        }
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
          'invalid' => 0,
        },
        {
          'ssf' => -1,
        },
        {
          'ssf' => 'invalid',
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
