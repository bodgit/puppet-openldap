require 'spec_helper'

describe 'openldap::flatten_checkpoint' do
  it { should run.with_params([0, 0]).and_return('0 0') }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params(0) }.to raise_error(/parameter 'value' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'value' /) }
end
