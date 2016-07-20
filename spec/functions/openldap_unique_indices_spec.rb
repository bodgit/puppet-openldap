require 'spec_helper'

describe 'openldap_unique_indices' do
  it { should run.with_params(
    ['entryCSN,entryUUID eq', 'ou,cn eq,pres,sub', 'entryCSN eq', 'entryUUID eq']
  ).and_return(
    ['entryCSN eq', 'entryUUID eq', 'ou eq,pres,sub', 'cn eq,pres,sub'])
  }
  it { should run.with_params(['entryCSN eq']).and_return(
    ['entryCSN eq'])
  }
  it { should run.with_params([]).and_return([]) }
end
