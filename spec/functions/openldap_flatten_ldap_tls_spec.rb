require 'spec_helper'

describe 'openldap::flatten_ldap_tls' do
  it { should run.with_params({'mode' => 'start', 'tls_cert' => '/tmp/cert.pem', 'tls_key' => '/tmp/key.pem', 'tls_cacert' => '/tmp/cacert.pem', 'tls_cacertdir' => '/tmp', 'tls_reqcert' => 'demand', 'tls_ciphersuite' => 'HIGH:MEDIUM:+SSLv2', 'tls_crlcheck' => 'peer'}).and_return('start tls_cert=/tmp/cert.pem tls_key=/tmp/key.pem tls_cacert=/tmp/cacert.pem tls_cacertdir=/tmp tls_reqcert=demand tls_ciphersuite=HIGH:MEDIUM:+SSLv2 tls_crlcheck=peer') }
  it { should run.with_params(:undef).and_return(nil) }
  it { should run.with_params(nil).and_return(nil) }
  it { expect { should run.with_params([]) }.to raise_error(/parameter 'value' /) }
  it { expect { should run.with_params('invalid') }.to raise_error(/parameter 'value' /) }
end
