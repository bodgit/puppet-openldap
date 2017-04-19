require 'spec_helper'

describe 'openldap::boolean' do
  it { should run.with_params(true).and_return('TRUE') }
  it { should run.with_params(false).and_return('FALSE') }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'value' /) }
  it { expect { should run.with_params([true]) }.to raise_error(/parameter 'value' /) }
end
