require 'spec_helper'

describe 'openldap::flatten_security' do
  it { should run.with_params({'ssf' => 0, 'transport' => 256}).and_return('ssf=0 transport=256') }
  it { should run.with_params({'transport' => 0, 'ssf' => 256}).and_return('transport=0 ssf=256') }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params([]) }.to raise_error(/parameter 'value' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'value' /) }
end
