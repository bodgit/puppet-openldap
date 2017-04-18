require 'spec_helper'

describe Puppet::Type.type(:openldap).provider(:olc) do

  before :each do
    Puppet::Type.type(:openldap).stubs(:defaultprovider).returns described_class
  end

  describe '.instances' do
    it 'should have an instances method' do
      expect(described_class).to respond_to(:instances)
    end

    it 'should get existing objects by running slapcat' do
      described_class.expects(:slapcat).with('-b', 'cn=config', '-o', 'ldif-wrap=no', '-H', 'ldap:///???(!(entryDN:dnSubordinateMatch:=cn=schema,cn=config))').returns File.read(my_fixture('slapcat'))
      expect(described_class.instances.map(&:name)).to eq([
        'cn=config',
        'cn=schema,cn=config',
        'olcDatabase={0}config,cn=config',
      ])
    end
  end
end
