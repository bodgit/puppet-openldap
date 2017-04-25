require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::limit::size', type: :class do
    describe 'accepts a size limit' do
      [
        0,
        100,
        'unlimited',
        {
          'soft'      => 0,
          'hard'      => 0,
          'unchecked' => 0,
          'pr'        => 0,
          'prtotal'   => 0,
        },
        {
          'soft'      => 'unlimited',
          'hard'      => 'unlimited',
          'unchecked' => 'unlimited',
          'pr'        => 'unlimited',
          'prtotal'   => 'unlimited',
        },
        {
          'soft'      => 100,
          'hard'      => 'soft',
          'unchecked' => 'disable',
          'pr'        => 'noEstimate',
          'prtotal'   => 'disabled',
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
        -1,
        'invalid',
        [0],
        {
          'soft' => 'disable',
        },
        {
          'hard' => 'disable',
        },
        {
          'soft' => 'soft',
        },
        {
          'unchecked' => 'soft',
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
