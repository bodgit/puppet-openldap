require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::loglevel', type: :class do
    describe 'accepts a log level' do
      [
        0,
        65535,
        0x0,
        0xffff,
        'trace',
        'packets',
        'args',
        'conns',
        'BER',
        'filter',
        'config',
        'ACL',
        'stats',
        'stats2',
        'shell',
        'parse',
        'sync',
        'none',
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
        65536,
        0x10000,
        'invalid',
        [0],
        ['none'],
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it {is_expected.to compile.and_raise_error(/parameter 'value' /) }
        end
      end
    end
  end
end
