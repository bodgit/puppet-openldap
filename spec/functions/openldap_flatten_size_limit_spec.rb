require 'spec_helper'

describe 'openldap::flatten_size_limit' do
  it { should run.with_params(0).and_return('0') }
  it { should run.with_params('unlimited').and_return('unlimited') }
  it { should run.with_params({'soft' => 0, 'hard' => 'unlimited', 'unchecked' => 'disable'}).and_return('size.soft=0 size.hard=unlimited size.unchecked=disable') }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params([]) }.to raise_error(/parameter 'value' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'value' /) }
end
