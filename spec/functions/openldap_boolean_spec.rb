require 'spec_helper'

describe 'openldap_boolean' do
  it { expect { should run.with_params() }.to raise_error(/Wrong number of arguments given/) }
  it { expect { should run.with_params(123) }.to raise_error(/is not a boolean/) }
  it { should run.with_params(nil).and_return(nil) }
  it { should run.with_params(true).and_return('TRUE') }
  it { should run.with_params(false).and_return('FALSE') }
end
