require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.4.0') >= 0
  describe 'test::passwordhash', type: :class do
    describe 'accepts a password hash' do
      [
        '{SSHA}',
        '{SHA}',
        '{SMD5}',
        '{MD5}',
        '{CRYPT}',
        '{CLEARTEXT}',
        '{SSHA256}',
        '{SSHA384}',
        '{SSHA512}',
        '{SHA256}',
        '{SHA384}',
        '{SHA512}',
        '{TOTP1}',
        '{TOTP256}',
        '{TOTP512}',
        '{PBKDF2}',
        '{PBKDF2-SHA1}',
        '{PBKDF2-SHA256}',
        '{PBKDF2-SHA512}',
        '{BSDMD5}',
        '{NS-MTA-MD5}',
        '{APR1}',
        '{RADIUS}',
        '{KERBEROS}',
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile }
        end
      end
    end
    describe 'rejects other values' do
      [
        '{INVALID}',
        123,
        ['{SSHA}'],
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it {is_expected.to compile.and_raise_error(/parameter 'value' /) }
        end
      end
    end
  end
end
