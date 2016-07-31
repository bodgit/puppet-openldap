require 'spec_helper'

describe 'validate_openldap_unique_uri' do
  it { expect { should run.with_params() }.to raise_error(/Wrong number of arguments given/) }
  it { expect { should run.with_params(123, 123) }.to raise_error(/Requires either an array or string to work with/) }
  it { expect { should run.with_params(123, [123]) }.to raise_error(/Requires either an array or string to work with/) }
  it { expect { should run.with_params('dc=example,dc=com', []) }.to raise_error(/Requires an array with at least 1 element/) }
  it { expect { should run.with_params('invalid', 'ldap:///ou=people,dc=example,dc=com?uidNumber?sub') }.to raise_error(/is not a valid LDAP distinguished name/) }
  it { expect { should run.with_params('dc=example,dc=com', ['invalid']) }.to raise_error(/is not a valid unique URI/) }
  it { expect { should run.with_params('dc=example,dc=com', ['ldap:///ou=people,dc=example,dc=org?uidNumber?sub']) }.to raise_error(/is not a valid unique URI/) }
  it { should run.with_params('dc=example,dc=com', ['ldap:///ou=people,dc=example,dc=com?uidNumber?sub']) }
  it { should run.with_params('dc=example,dc=com', ['strict ldap:///ou=people,dc=example,dc=com?uidNumber?sub']) }
  it { should run.with_params('dc=example,dc=com', ['ignore ldap:///ou=people,dc=example,dc=com?uidNumber?sub']) }
  it { should run.with_params('dc=example,dc=com', ['strict ignore ldap:///ou=people,dc=example,dc=com?uidNumber?sub']) }
end
