require 'spec_helper'

describe A9n::Struct do
  subject {
    described_class.new({
        non_empty_dwarf: 'dwarf',
        nil_dwarf:   nil,
        false_dwarf: false,
        true_dwarf:  true,
        hash_dwarf:  { dwarf: 'hello' }
      })
  }

  its(:keys) { should == [:non_empty_dwarf, :nil_dwarf, :false_dwarf, :true_dwarf, :hash_dwarf] }

  it 'gets non-empty value' do
    subject.non_empty_dwarf.should == 'dwarf'
  end

  it 'gets nil value' do
    subject.nil_dwarf.should == nil
  end

  it 'gets true value' do
    subject.true_dwarf.should == true
  end
  
  it 'gets false value' do
    subject.false_dwarf.should == false
  end

  it 'gets hash value' do
    subject.hash_dwarf.should be_kind_of(Hash)
  end

  it 'raises exception when value not exists' do
    expect { 
      subject.non_existing_dwarf
    }.to raise_error(A9n::NoSuchConfigurationVariable)
  end

  describe '#fetch' do
    it 'return non empty value' do
      subject.fetch(:non_empty_dwarf).should == 'dwarf'
    end

    it 'not returns nil for non existing value' do
      subject.fetch(:non_existing_dwarf).should == nil
    end
  end
end