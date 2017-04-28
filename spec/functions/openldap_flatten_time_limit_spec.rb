require 'spec_helper'

describe 'openldap::flatten_time_limit' do
  it { should run.with_params(0).and_return('0') }
  it { should run.with_params('unlimited').and_return('unlimited') }
  it { should run.with_params({'soft' => 0, 'hard' => 'unlimited'}).and_return('time.soft=0 time.hard=unlimited') }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params([]) }.to raise_error(/parameter 'value' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'value' /) }
end
