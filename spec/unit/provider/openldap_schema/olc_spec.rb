require 'spec_helper'

describe Puppet::Type.type(:openldap_schema).provider(:olc) do

  before :each do
    Puppet::Type.type(:openldap_schema).stubs(:defaultprovider).returns described_class
  end

  describe '.instances' do
    it 'should have an instances method' do
      expect(described_class).to respond_to(:instances)
    end

    it 'should get existing objects by running slapcat' do
      described_class.expects(:slapcat).with('-b', 'cn=config', '-o', 'ldif-wrap=no', '-H', 'ldap:///???(entryDN:dnSubordinateMatch:=cn=schema,cn=config)').returns File.read(my_fixture('slapcat'))
      expect(described_class.instances.map(&:name)).to eq([
        'core',
      ])
    end
  end

  describe '#flush' do
    it 'should import a local LDIF file by filename' do
      provider = described_class.new(Puppet::Type.type(:openldap_schema).new(
        :name  => 'cosine',
        :ldif  => '/etc/openldap/schema/cosine.ldif',
      ))
      provider.expects(:ldapmodify).with('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-a', '-f', '/etc/openldap/schema/cosine.ldif')
      provider.create
      provider.flush
    end

    it 'should import a local LDIF file by URL' do
      provider = described_class.new(Puppet::Type.type(:openldap_schema).new(
        :name  => 'cosine',
        :ldif  => 'file:/etc/openldap/schema/cosine.ldif',
      ))
      provider.expects(:ldapmodify).with('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-a', '-f', '/etc/openldap/schema/cosine.ldif')
      provider.create
      provider.flush
    end

    it 'should import an LDIF file by Puppet URL' do
      #provider = described_class.new(Puppet::Type.type(:openldap_schema).new(
      #  :name  => 'cosine',
      #  :ldif  => 'puppet:///modules/openldap/cosine.ldif',
      #))
      #provider.expects(:ldapmodify).with('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-a', '-f', '/etc/openldap/schema/cosine.ldif')
      #provider.create
      #provider.flush
    end
  end
end
