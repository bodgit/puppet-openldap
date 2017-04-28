require 'spec_helper'

describe 'openldap::flatten_limits' do
  it { should run.with_params([{'selector' => 'users', 'size' => 0}]).and_return(['users size=0']) }
  it { should run.with_params([{'selector' => 'users', 'size' => 'unlimited'}]).and_return(['users size=unlimited']) }
  it { should run.with_params([{'selector' => 'users', 'time' => 0}]).and_return(['users time=0']) }
  it { should run.with_params([{'selector' => 'users', 'time' => 'unlimited'}]).and_return(['users time=unlimited']) }
  it { should run.with_params([{'selector' => 'users', 'size' => {'soft' => 0, 'hard' => 'unlimited'}, 'time' => {'soft' => 0, 'hard' => 'unlimited'}}]).and_return(['users size.soft=0 size.hard=unlimited time.soft=0 time.hard=unlimited']) }
  it { should run.with_params([{'selector' => 'users', 'time' => {'soft' => 0, 'hard' => 'unlimited'}, 'size' => {'soft' => 0, 'hard' => 'unlimited'}}]).and_return(['users size.soft=0 size.hard=unlimited time.soft=0 time.hard=unlimited']) }
  it { should run.with_params([{'time' => {'soft' => 0, 'hard' => 'unlimited'}, 'size' => {'soft' => 0, 'hard' => 'unlimited'}, 'selector' => 'users'}]).and_return(['users size.soft=0 size.hard=unlimited time.soft=0 time.hard=unlimited']) }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params([]) }.to raise_error(/parameter 'values' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'values' /) }
end
