require 'spec_helper'

describe 'openldap::values' do
  it { should run.with_params(['foo', 'bar']).and_return(['{0}foo', '{1}bar']) }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { should run.with_params([]).and_return([]) }
  it { expect { should run.with_params('foo') }.to raise_error(/parameter 'values' /) }
  it { expect { should run.with_params(123) }.to raise_error(/parameter 'values' /) }
end
