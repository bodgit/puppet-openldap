require 'spec_helper'

describe Puppet::Type.type(:openldap_schema) do

  it "should have :name as its keyattribute" do
    expect(described_class.key_attributes).to eq([:name])
  end

  describe 'when validating attributes' do
    [:name, :provider, :ldif, :service].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:ensure].each do |property|
      it "should have a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end
  end

  describe 'when validating value' do
    describe 'for ldif' do
      it 'should support a local filename' do
        expect(described_class.new(:name => 'cn=config', :ldif => '/tmp/test.ldif', :ensure => :present)[:ldif]).to eq('file:/tmp/test.ldif')
      end

      it 'should support a file url' do
        expect(described_class.new(:name => 'cn=config', :ldif => 'file:/tmp/test.ldif', :ensure => :present)[:ldif]).to eq('file:/tmp/test.ldif')
      end

      it 'should support a puppet url' do
        expect(described_class.new(:name => 'cn=config', :ldif => 'puppet:///modules/openldap/test.ldif', :ensure => :present)[:ldif]).to eq('puppet:///modules/openldap/test.ldif')
      end

      it 'should error with an invalid url' do
        expect{described_class.new(:name => 'cn=config', :ldif => ':', :ensure => :present)}.to raise_error(/Could not understand LDIF/)
      end
    end

    describe 'autorequire' do
      let(:catalog) {
        catalog = Puppet::Resource::Catalog.new
      }
      it 'should autorequire a local file' do
        file = Puppet::Type.type(:file).new(:name => '/tmp/test.ldif', :content => 'test')
        catalog.add_resource file
        key = described_class.new(:name => 'cn=config', :ldif => '/tmp/test.ldif', :ensure => :present)
        catalog.add_resource key
        expect(key.autorequire.size).to eq(1)
      end
    end
  end
end
