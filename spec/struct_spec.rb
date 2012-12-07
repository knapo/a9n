require 'spec_helper'

describe A9n::Struct do
  subject {
    described_class.new({
        :non_empty_dwarf => 'dwarf',
        :nil_dwarf       => nil,
        :false_dwarf     => false,
        :true_dwarf      => true
      })
  }

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

  it 'raises exception when value not exists' do
    expect { 
      subject.non_existing_dwarf
    }.to raise_error(A9n::NoSuchConfigurationVariable)
  end
end