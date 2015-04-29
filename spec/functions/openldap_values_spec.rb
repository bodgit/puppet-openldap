require 'spec_helper'

describe 'openldap_values' do
  it { should run.with_params(['foo', 'bar']).and_return(['{0}foo', '{1}bar']) }
  it { should run.with_params('foo').and_return(['{0}foo']) }
  it { should run.with_params([]).and_return([]) }
end
