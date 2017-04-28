require 'spec_helper'

describe 'openldap::flatten_syncrepl' do
  it { should run.with_params([{'rid' => 1, 'provider' => 'ldap://ldap.example.com', 'searchbase' => 'dc=example,dc=com', 'type' => 'refreshAndPersist', 'bindmethod' => 'simple', 'binddn' => 'cn=Manager,dc=example,dc=com', 'credentials' => 'secret', 'logbase' => 'cn=log', 'logfilter' => '(&(objectClass=auditWriteObject)(reqResult=0))', 'schemachecking' => true, 'syncdata' => 'accesslog', 'retry' => [[5, 5], [300, '+']]}]).and_return(['rid=001 provider=ldap://ldap.example.com searchbase="dc=example,dc=com" type=refreshAndPersist bindmethod=simple binddn="cn=Manager,dc=example,dc=com" credentials=secret logbase="cn=log" logfilter="(&(objectClass=auditWriteObject)(reqResult=0))" schemachecking=on syncdata=accesslog retry="5 5 300 +"']) }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params([]) }.to raise_error(/parameter 'values' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'values' /) }
end
