RSpec.describe A9n::Loader do
  subject { described_class.new(file_path, scope, env) }

  let(:scope) { A9n::Scope.new('a9n') }
  let(:env) { 'test' }
  let(:root) { File.expand_path('../../test_app', __dir__) }
  let(:file_path) { File.join(root, 'config/a9n.yml') }

  describe '#intialize' do
    it { expect(subject.scope).to eq(scope) }
    it { expect(subject.env).to eq(env) }
    it { expect(subject.local_file).to eq(file_path) }
    it { expect(subject.example_file).to eq("#{file_path}.example") }
  end

  describe '#load' do
    let(:example_config) do
      { app_url: 'http://127.0.0.1:3000', api_key: 'example1234' }
    end

    let(:local_config) do
      { app_host: '127.0.0.1:3000', api_key: 'local1234' }
    end

    let(:env) { 'tropical' }
    let(:config) { subject.get }

    context 'when no configuration file exists' do
      before do
        expect(described_class).to receive(:load_yml).with(subject.example_file, scope, env).and_return(nil)
        expect(described_class).to receive(:load_yml).with(subject.local_file, scope, env).and_return(nil)
      end

      it 'raises expection' do
        expect {
          subject.load
        }.to raise_error(A9n::MissingConfigurationDataError)
      end
    end

    context 'when only example configuration file exists' do
      before do
        expect(described_class).to receive(:load_yml).with(subject.example_file, scope, env).and_return(example_config)
        expect(described_class).to receive(:load_yml).with(subject.local_file, scope, env).and_return(nil)
        subject.load
      end

      it { expect(config.app_url).to eq('http://127.0.0.1:3000') }
      it { expect(config.api_key).to eq('example1234') }

      it do
        expect { config.app_host }.to raise_error(A9n::KeyNotFoundError)
      end
    end

    context 'when only local configuration file exists' do
      before do
        expect(described_class).to receive(:load_yml).with(subject.example_file, scope, env).and_return(nil)
        expect(described_class).to receive(:load_yml).with(subject.local_file, scope, env).and_return(local_config)
        subject.load
      end

      it { expect(config.app_host).to eq('127.0.0.1:3000') }
      it { expect(config.api_key).to eq('local1234') }

      it do
        expect { config.app_url }.to raise_error(A9n::KeyNotFoundError)
      end
    end

    context 'when both local and base configuration file exists without defaults' do
      context 'with same data' do
        before do
          expect(described_class).to receive(:load_yml).with(subject.example_file, scope, env).and_return(example_config)
          expect(described_class).to receive(:load_yml).with(subject.local_file, scope, env).and_return(example_config)
          subject.load
        end

        it { expect(config.app_url).to eq('http://127.0.0.1:3000') }
        it { expect(config.api_key).to eq('example1234') }

        it do
          expect { config.app_host }.to raise_error(A9n::KeyNotFoundError)
        end
      end

      context 'with different data' do
        before do
          expect(described_class).to receive(:load_yml).with(subject.example_file, scope, env).and_return(example_config)
          expect(described_class).to receive(:load_yml).with(subject.local_file, scope, env).and_return(local_config)
        end

        let(:missing_variables_names) { example_config.keys - local_config.keys }

        it 'raises expection with missing variables names'  do
          expect {
            subject.load
          }.to raise_error(A9n::MissingConfigurationVariablesError, /#{missing_variables_names.join(', ')}/)
        end
      end
    end
  end

  describe '.load_yml' do
    subject { described_class.load_yml(file_path, scope, env) }

    let(:env) { 'test' }

    context 'when file not exists' do
      let(:file_path) { 'file_not_existing_in_the_universe.yml' }

      it { expect(subject).to be_nil }
    end

    context 'when file exists' do
      shared_examples 'non-empty config file' do
        it 'returns non-empty hash' do
          expect(subject).to be_kind_of(Hash)
          expect(subject).to be_frozen
          expect(subject.keys).not_to be_empty
        end
      end

      before do
        ENV['ERB_FOO'] = 'erbized foo'
        ENV['FOO_PASSWORD'] = 'foo123'
        ENV['FOO_KEY'] = 'key123'
      end

      after do
        ENV.delete('ERB_FOO')
        ENV.delete('FOO_PASSWORD')
        ENV.delete('FOO_KEY')
      end

      context 'when file has erb extension' do
        let(:file_path) { File.join(root, 'config/a9n/cloud.yml.erb') }

        it_behaves_like 'non-empty config file'
      end

      context 'having env and defaults data' do
        let(:file_path) { File.join(root, 'config/a9n.yml') }

        it_behaves_like 'non-empty config file'

        it 'contains only frozen values' do
          expect(subject.values.reject(&:frozen?)).to eq([])
        end

        it 'contains keys from defaults scope' do
          expect(subject[:default_foo]).to eq('default foo')
          expect(subject[:overriden_foo]).to eq('already overriden foo')
        end

        it 'has symbolized keys' do
          expect(subject.keys.first).to be_kind_of(Symbol)
          expect(subject[:hash_foo]).to be_kind_of(Hash)
          expect(subject[:hash_foo].keys.first).to be_kind_of(Symbol)
          expect(subject[:hash_foo]).to eq(foo1: 'hello 1', foo2: 'hello 2', foo_key: 'key123')
        end

        it 'parses erb' do
          expect(subject[:erb_foo]).to eq('erbized foo')
        end

        it 'gets valus from ENV' do
          expect(subject[:foo_password]).to eq('foo123')
        end

        it 'raises exception when ENV var is not set' do
          ENV.delete('FOO_PASSWORD')
          expect { subject[:foo_password] }.to raise_error(A9n::MissingEnvVariableError)
        end

        it 'raises exception when ENV var is set to nil' do
          ENV['FOO_PASSWORD'] = nil
          expect { subject[:foo_password] }.to raise_error(A9n::MissingEnvVariableError)
        end
      end

      context 'having no env and only defaults data' do
        let(:file_path) { File.join(root, 'config/a9n.yml') }
        let(:env) { 'production' }

        it_behaves_like 'non-empty config file'

        it 'contains keys from defaults scope' do
          expect(subject[:default_foo]).to eq('default foo')
          expect(subject[:overriden_foo]).to eq('not yet overriden foo')
        end
      end

      context 'having only env and no default data' do
        let(:file_path) { File.join(root, 'config/no_defaults.yml') }

        context 'valid env' do
          let(:env) { 'production' }

          it_behaves_like 'non-empty config file'
        end

        context 'invalid env' do
          let(:env) { 'tropical' }

          it { expect(subject).to be_nil }
        end
      end
    end
  end
end
