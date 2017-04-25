require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::index::type', type: :class do
    describe 'accepts a backend' do
      [
        'pres',
        'eq',
        'approx',
        'sub',
        'subinitial',
        'subany',
        'subfinal',
        'nolang',
        'nosubtypes',
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
        ['pres'],
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it {is_expected.to compile.and_raise_error(/parameter 'value' /) }
        end
      end
    end
  end
end
