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

  describe '#keys' do
    subject { super().keys }
    it { should == [:non_empty_dwarf, :nil_dwarf, :false_dwarf, :true_dwarf, :hash_dwarf] }
  end

  it 'gets non-empty value' do
    expect(subject.non_empty_dwarf).to eq('dwarf')
  end

  it 'gets nil value' do
    expect(subject.nil_dwarf).to eq(nil)
  end

  it 'gets true value' do
    expect(subject.true_dwarf).to eq(true)
  end

  it 'gets false value' do
    expect(subject.false_dwarf).to eq(false)
  end

  it 'gets hash value' do
    expect(subject.hash_dwarf).to be_kind_of(Hash)
  end

  it 'raises exception when value not exists' do
    expect {
      subject.non_existing_dwarf
    }.to raise_error(A9n::NoSuchConfigurationVariable)
  end

  describe '#fetch' do
    it 'return non empty value' do
      expect(subject.fetch(:non_empty_dwarf)).to eq('dwarf')
    end

    it 'not returns nil for non existing value' do
      expect(subject.fetch(:non_existing_dwarf)).to eq(nil)
    end
  end
end
