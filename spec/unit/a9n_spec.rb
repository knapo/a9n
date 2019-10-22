RSpec.describe A9n do
  subject { described_class }
  before { clean_singleton(subject) }
  after { clean_singleton(subject) }

  describe '.env' do
    before do
      subject.instance_variable_set(:@env, nil)
    end

    context 'app_env is set' do
      let(:app) { OpenStruct.new(env: ::A9n::StringInquirer.new('foo_env')) }

      before do
        allow(subject).to receive(:app).and_return(app)
        expect(subject).to receive(:env_var).never
      end

      it do
        expect(subject.env).to eq('foo_env')
        expect(subject.env.foo_env?).to eq(true)
        expect(subject.env.production?).to eq(false)
      end
    end

    context 'when APP_ENV is set' do
      before do
        expect(subject).to receive(:app_env).and_return(nil)
        expect(subject).to receive(:env_var).with('RAILS_ENV').and_return(nil)
        expect(subject).to receive(:env_var).with('RACK_ENV').and_return(nil)
        expect(subject).to receive(:env_var).with('APP_ENV').and_return('foo_env')
      end

      it do
        expect(subject.env).to eq('foo_env')
        expect(subject.env.foo_env?).to eq(true)
        expect(subject.env.production?).to eq(false)
      end
    end

    context 'unknown env' do
      before do
        expect(subject).to receive(:app_env).and_return(nil)
        expect(subject).to receive(:env_var).with('RAILS_ENV').and_return(nil)
        expect(subject).to receive(:env_var).with('RACK_ENV').and_return(nil)
        expect(subject).to receive(:env_var).with('APP_ENV').and_return(nil)
      end

      it do
        expect { subject.env }.to raise_error(A9n::UnknownEnvError)
      end
    end
  end

  describe '.groups' do
    before do
      subject.env = 'development'
    end

    it do
      expect(subject.groups).to eq(%w[default development])
      expect(subject.groups).to be_frozen
    end
  end

  describe '.app' do
    context 'when rails not found' do
      before do
        expect(subject).to receive(:rails_app).and_return(nil)
      end

      it do
        expect(subject.app).to be_nil
      end
    end

    context 'when rails app is being used' do
      let(:app) { double(env: 'test', root: '/apps/a9n') }

      before do
        expect(subject).to receive(:rails_app).and_return(app)
      end

      it do
        expect(subject.app).to eq(app)
      end
    end

    context 'when custom non-rails app is being used' do
      let(:app) { double(env: 'test', root: '/apps/a9n') }

      before do
        subject.app = app
      end

      it do
        expect(subject.app).to eq(app)
      end
    end
  end

  describe '.root' do
    context 'when app is set' do
      let(:app) { OpenStruct.new(env: 'test', root: '/apps/a9n') }

      before do
        subject.app = app
      end

      context 'with custom path' do
        before do
          subject.root = '/home/knapo/workspace/a9n'
        end

        it do
          expect(subject.root).to eq(Pathname.new('/home/knapo/workspace/a9n'))
          expect(subject.root).to be_frozen
        end
      end

      context 'with local app path' do
        it do
          expect(subject.root).to eq('/apps/a9n')
        end
      end
    end

    context 'when app is not set' do
      it do
        expect(subject.root).to eq(nil)
      end

      context 'when setting a custom path when is falsy' do
        before do
          subject.root ||= '/home/knapo/workspace/a9n'
        end

        it do
          expect(subject.root).to eq(Pathname.new('/home/knapo/workspace/a9n'))
        end
      end

      context 'when setting a custom path' do
        before do
          subject.root = '/home/knapo/workspace/a9n'
        end

        it do
          expect(subject.root).to eq(Pathname.new('/home/knapo/workspace/a9n'))
        end
      end
    end
  end

  describe '.rails_app' do
    context 'when defined' do
      before do
        Object.const_set(:Rails, Module.new)
      end

      after do
        Object.send(:remove_const, :Rails)
      end

      it do
        expect(subject.rails_app).to be_kind_of(Module)
      end
    end

    context 'when not defined' do
      it do
        expect(subject.rails_app).to be_nil
      end
    end
  end

  describe '.env_var' do
    before do
      ENV['FOO'] = 'little foo'
    end

    it do
      expect(subject.env_var('FOO')).to eq('little foo')
      expect(subject.env_var('FOO')).to be_frozen
    end

    it do
      expect(subject.env_var('IS_FOO')).to be_nil
    end
  end

  describe '.default_files' do
    before do
      subject.root = File.expand_path('../../test_app', __dir__)
    end

    it do
      expect(subject.default_files[0]).to include('a9n.yml')
      expect(Pathname.new(subject.default_files[0])).to be_absolute
      expect(subject.default_files[1]).to include('a9n/aws.yml')
      expect(Pathname.new(subject.default_files[1])).to be_absolute
    end
  end

  describe '.load' do
    before do
      expect(described_class).to receive(:env).exactly(2).times.and_return('dev')
      subject.root = '/apps/test_app'
      files.each do |f, cfg|
        expect(A9n::Loader).to receive(:new).with(f, kind_of(A9n::Scope), 'dev').and_return(double(get: cfg))
      end
    end

    context 'when no files given' do
      let(:files) do
        {
          '/apps/test_app/config/file1.yml' => { host: 'host1.com' },
          '/apps/test_app/config/dir/file2.yml' => { host: 'host2.com' }
        }
      end

      before do
        expect(subject).to receive(:default_files).and_return(files.keys)
        expect(subject).to receive(:absolute_paths_for).never
      end

      it do
        expect(subject.load).to eq(files.values)
      end
    end

    context 'when custom files given' do
      let(:given_files) do
        ['file3.yml', '/apps/test_app/config/dir/file4.yml']
      end

      let(:files) do
        {
          '/apps/test_app/config/file3.yml' => { host: 'host3.com' },
          '/apps/test_app/config/dir/file4.yml' => { host: 'host4.com' }
        }
      end

      before do
        expect(subject).to receive(:default_files).never
        expect(subject).to receive(:absolute_paths_for).with(given_files).and_call_original
      end

      it do
        expect(subject.load(*given_files)).to eq(files.values)
      end
    end
  end

  describe '.method_missing' do
    context 'when storage is empty' do
      before do
        expect(subject).to receive(:load).once
      end

      it do
        expect(subject.storage).to be_empty
        expect { subject.whatever }.to raise_error(A9n::NoSuchConfigurationVariableError)
      end
    end

    context 'when storage is not empty' do
      before do
        subject.storage[:whenever] = 'whenever'
        expect(subject).not_to receive(:load)
      end

      it do
        expect { subject.whatever }.to raise_error(A9n::NoSuchConfigurationVariableError)
      end
    end
  end
end
