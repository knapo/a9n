RSpec.describe A9n::Struct do
  context 'without any values' do
    subject { described_class.new }

    describe '#empty?' do
      it { expect(subject).to be_empty }
    end

    describe '#keys' do
      it { expect(subject.keys).to eq([]) }
    end

    describe '#key?' do
      it { expect(subject.key?(:foo)).to eq(false) }
    end

    describe '#[]' do
      it { expect(subject[:foo]).to eq(nil) }
    end

    describe '#fetch' do
      it do
        expect { subject.fetch(:foo) }.to raise_error(KeyError)
      end

      it do
        expect(subject.fetch(:foo, 'hello')).to eq('hello')
      end
    end

    describe '#find' do
      it do
        expect { subject.find(:foo) }.to raise_error(A9n::KeyNotFoundError)
      end
    end

    it 'raises error on accessin invalid attribute' do
      expect {
        subject.foo
      }.to raise_error(A9n::KeyNotFoundError, 'Could not find foo in []')
    end
  end

  context 'with values' do
    subject { described_class.new(data) }

    let(:data) do
      {
        non_empty_foo: 'foo',
        nil_foo: nil,
        false_foo: false,
        true_foo: true,
        hash_foo: { foo: 'hello' }
      }
    end

    describe '#keys' do
      it do
        expect(subject.keys).to eq [:non_empty_foo, :nil_foo, :false_foo, :true_foo, :hash_foo]
      end
    end

    describe '#to_h' do
      it do
        expect(subject.to_h).to be_kind_of(Hash)
        expect(subject.to_h).to eq(data)
      end
    end

    describe '#to_hash' do
      it do
        expect(subject.to_hash).to be_kind_of(Hash)
        expect(subject.to_hash).to eq(data)
      end
    end

    describe '#key?' do
      it { expect(subject.key?(:nil_foo)).to eq(true) }
      it { expect(subject.key?(:unknown)).to eq(false) }
    end

    describe '#merge' do
      before { subject.merge(argument) }

      context 'hash' do
        let(:argument) { { non_empty_foo: 'hello foo' } }

        it do
          expect(subject.non_empty_foo).to eq('hello foo')
        end
      end

      context 'struct' do
        let(:argument) { described_class.new(non_empty_foo: 'hello foo') }

        it do
          expect(subject.non_empty_foo).to eq('hello foo')
        end
      end
    end

    it 'is not empty' do
      expect(subject).not_to be_empty
    end

    it 'gets non-empty value' do
      expect(subject.non_empty_foo).to eq('foo')
    end

    it 'gets nil value' do
      expect(subject.nil_foo).to eq(nil)
    end

    it 'gets true value' do
      expect(subject.true_foo).to eq(true)
    end

    it 'gets false value' do
      expect(subject.false_foo).to eq(false)
    end

    it 'gets hash value' do
      expect(subject.hash_foo).to be_kind_of(Hash)
    end

    it 'raises exception when value not exists' do
      expect {
        subject.non_existing_foo
      }.to raise_error(
        A9n::KeyNotFoundError,
        'Could not find non_existing_foo in [:non_empty_foo, :nil_foo, :false_foo, :true_foo, :hash_foo]'
      )
    end

    describe '#[]' do
      it 'returns non empty value' do
        expect(subject[:non_empty_foo]).to eq('foo')
      end

      it 'returns false value' do
        expect(subject[:false_foo]).to eq(false)
      end

      it 'returns nil value' do
        expect(subject[:nil_foo]).to eq(nil)
      end

      it 'returns nil for non existing key' do
        expect(subject[:non_existing_foo]).to eq(nil)
      end
    end

    describe '#find' do
      it 'returns non empty value' do
        expect(subject.find(:non_empty_foo)).to eq('foo')
      end

      it 'returns false value' do
        expect(subject.find('false_foo')).to eq(false)
      end

      it 'returns nil value' do
        expect(subject.find(:nil_foo)).to eq(nil)
      end

      it 'raises error for non existing key' do
        expect {
          subject.find(:non_existing_foo)
        }.to raise_error(A9n::KeyNotFoundError)
      end
    end

    describe '#fetch' do
      it 'returns non empty value' do
        expect(subject.fetch(:non_empty_foo)).to eq('foo')
      end

      it 'returns false value' do
        expect(subject.fetch(:false_foo)).to eq(false)
      end

      it 'returns nil value' do
        expect(subject.fetch(:nil_foo)).to eq(nil)
      end

      it 'returns default for non existing value' do
        expect(subject.fetch(:non_existing_foo, 'hello')).to eq('hello')
      end

      it 'raises error for non existing key' do
        expect {
          subject.fetch(:non_existing_foo)
        }.to raise_error(KeyError)
      end
    end
  end
end
