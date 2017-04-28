require 'spec_helper'

describe 'openldap::flatten_indices' do
  it { should run.with_params([[['entryCSN', 'entryUUID'], ['eq']]]).and_return(['entryCSN,entryUUID eq']) }
  it { should run.with_params([[['entryCSN', 'entryUUID']]]).and_return(['entryCSN,entryUUID']) }
  it { should run.with_params([[['default'], ['eq']]]).and_return(['default eq']) }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params([]) }.to raise_error(/parameter 'values' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'values' /) }
end
