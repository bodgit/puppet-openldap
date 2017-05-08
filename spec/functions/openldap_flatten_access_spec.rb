require 'spec_helper'

describe 'openldap::flatten_access' do
  it { should run.with_params([[{'dn' => '*'}, [{'who' => ['dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"'], 'access' => 'manage'}]]]).and_return(['to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage']) }
  it { should run.with_params([[{'attrs' => ['userPassword']}, [{'who' => ['anonymous'], 'access' => 'auth'}]]]).and_return(['to attrs=userPassword by anonymous auth']) }
  it { should run.with_params([[{'attrs' => ['userPassword']}, [{'who' => ['self'], 'access' => '=xw'}, {'who' => ['anonymous'], 'access' => 'auth'}]], [{'dn' => '*'}, [{'who' => ['dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"'], 'access' => 'manage'}, {'who' => ['self'], 'access' => 'write'}, {'who' => ['users'], 'access' => 'read'}]]]).and_return(['to attrs=userPassword by self =xw by anonymous auth', 'to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by self write by users read']) }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params([]) }.to raise_error(/parameter 'values' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'values' /) }
end
