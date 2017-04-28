require 'spec_helper'

describe 'openldap::flatten_generic' do
  it { should run.with_params(['foo', 'bar', 0, 0xff]).and_return('foo bar 0 255') }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'values' /) }
  it { expect { should run.with_params([true]) }.to raise_error(/parameter 'values' /) }
end
