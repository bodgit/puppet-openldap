require 'spec_helper'

describe 'openldap::flatten_ldap_id_assert_bind' do
  it { should run.with_params({'bindmethod' => 'simple', 'binddn' => 'cn=Manager,dc=example,dc=com', 'credentials' => 'secret', 'mode' => 'self', 'flags' => ['override', 'prescriptive']}).and_return('bindmethod=simple binddn="cn=Manager,dc=example,dc=com" credentials=secret mode=self flags=override,prescriptive') }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params([]) }.to raise_error(/parameter 'value' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'value' /) }
end
