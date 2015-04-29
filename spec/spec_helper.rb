require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true

  c.before(:each) do
    Puppet.features.stubs(:root? => true)
  end
end

dir = Pathname.new(__FILE__).parent

Puppet[:modulepath] = File.join(dir, 'fixtures', 'modules')
Puppet[:libdir] = File.join(Puppet[:modulepath], 'stdlib', 'lib')

shared_examples :compile, :compile => true do
  it { should compile.with_all_deps }
end

at_exit { RSpec::Puppet::Coverage::report! }
