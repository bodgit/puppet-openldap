require 'spec_helper'

describe 'openldap::flatten_unique' do
  it { should run.with_params([{'uri' => ['ldap:///dc=example,dc=com?uidNumber?sub']}]).and_return(['ldap:///dc=example,dc=com?uidNumber?sub']) }
  it { should run.with_params([{'strict' => true, 'uri' => ['ldap:///dc=example,dc=com?uidNumber?sub']}]).and_return(['strict ldap:///dc=example,dc=com?uidNumber?sub']) }
  it { should run.with_params([{'ignore' => true, 'uri' => ['ldap:///dc=example,dc=com?uidNumber?sub']}]).and_return(['ignore ldap:///dc=example,dc=com?uidNumber?sub']) }
  it { should run.with_params([{'strict' => true, 'ignore' => true, 'uri' => ['ldap:///dc=example,dc=com?uidNumber?sub']}]).and_return(['strict ignore ldap:///dc=example,dc=com?uidNumber?sub']) }
  it { should run.with_params([{'strict' => false, 'uri' => ['ldap:///dc=example,dc=com?uidNumber?sub']}]).and_return(['ldap:///dc=example,dc=com?uidNumber?sub']) }
  it { should run.with_params([{'ignore' => false, 'uri' => ['ldap:///dc=example,dc=com?uidNumber?sub']}]).and_return(['ldap:///dc=example,dc=com?uidNumber?sub']) }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params([]) }.to raise_error(/parameter 'values' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'values' /) }
end
