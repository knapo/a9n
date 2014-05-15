require 'spec_helper'

describe A9n do
  describe '.local_app' do
    context 'when rails not found' do
      before {
        expect(described_class).to receive(:get_rails).and_return(nil)
      }
      specify {
        described_class.local_app.should be_nil
      }
    end

    context 'when custom non-rails app is being used' do
      let(:local_app) { double(env: 'test', root: '/apps/a9n') }
      before { described_class.local_app = local_app }

      specify { described_class.local_app.should == local_app }
    end

    after { described_class.local_app = nil }
  end

  describe '.root' do
    let(:local_app) { double(env: 'test', root: '/apps/a9n') }
    before { described_class.local_app = local_app }

    context 'with custom path' do
      before {
        described_class.root = '/home/knapo/workspace/a9n'
      }
      specify {
        described_class.root.should == Pathname.new('/home/knapo/workspace/a9n')
      }
    end

    context 'with local app path' do
      specify {
        described_class.root.should == '/apps/a9n'
      }
    end

    after {
      described_class.root = nil
      described_class.local_app = nil
    }
  end

  describe '.load' do
    let(:base_file) { described_class::DEFAULT_FILE }
    let(:extra_file) { 'mongo.yml' }
    let(:base_sample_config){
      { app_url: 'http://127.0.0.1:3000', api_key: 'base1234' }
    }
    let(:local_sample_config){
      { app_host: '127.0.0.1:3000', api_key: 'local1234' }
    }
    let(:base_default_config){
      { page_title: 'Base Kielbasa', api_key: 'base1234default'  }
    }
    let(:local_default_config){
      { page_title: 'Local Kielbasa', api_key: 'local1234default' }
    }
    let(:env){
      'tropical'
    }
    subject {
      described_class
    }
    before do
      allow(described_class).to receive(:env).and_return(env)
    end

    context 'when no configuration file exists' do
      before do
        expect(described_class).to receive(:load_yml).with("config/#{base_file}.example", env).and_return(nil)
        expect(described_class).to receive(:load_yml).with("config/#{base_file}", env).and_return(nil)
        expect(described_class).to receive(:load_yml).with("config/#{base_file}.example", 'defaults').and_return(nil)
        expect(described_class).to receive(:load_yml).with("config/#{base_file}", 'defaults').and_return(nil)
        expect(described_class).to receive(:verify!).never
      end
      it 'raises expection'  do
        lambda {
          described_class.load
        }.should raise_error(described_class::MissingConfigurationData)
      end
    end

    context 'when base configuration file exists with defaults' do
      before do
        expect(described_class).to receive(:load_yml).with("config/#{base_file}.example", env).and_return(base_sample_config)
        expect(described_class).to receive(:load_yml).with("config/#{base_file}", env).and_return(nil)
        expect(described_class).to receive(:load_yml).with("config/#{base_file}.example", 'defaults').and_return(base_default_config)
        expect(described_class).to receive(:load_yml).with("config/#{base_file}", 'defaults').and_return(nil)

        expect(described_class).to receive(:verify!).never
        described_class.load
      end

      its(:app_url) { should_not be_nil }
      its(:app_url) { should == subject.fetch(:app_url) }
      its(:page_title) { should == 'Base Kielbasa' }
      its(:api_key) { should == 'base1234' }
      specify {
        expect(subject.instance_variable_get("@configuration")).to be_kind_of(A9n::Struct)
      }
      specify {
        expect { subject.app_host }.to raise_error(described_class::NoSuchConfigurationVariable)
      }
    end

    context 'when local configuration file exists with defaults' do
      before do
        expect(described_class).to receive(:load_yml).with("config/#{base_file}.example", env).and_return(nil)
        expect(described_class).to receive(:load_yml).with("config/#{base_file}", env).and_return(local_sample_config)
        expect(described_class).to receive(:load_yml).with("config/#{base_file}.example", 'defaults').and_return(nil)
        expect(described_class).to receive(:load_yml).with("config/#{base_file}", 'defaults').and_return(local_default_config)
        expect(described_class).to receive(:verify!).never
        described_class.load
      end

      its(:app_host) { should_not be_nil }
      its(:page_title) { should == 'Local Kielbasa' }
      its(:api_key) { should == 'local1234' }
      specify {
        expect { subject.app_url }.to raise_error(described_class::NoSuchConfigurationVariable)
      }
    end

    context 'when both local and base configuration file exists without defaults' do
      context 'with same data' do
        before do
          expect(described_class).to receive(:load_yml).with("config/#{base_file}.example", env).and_return(base_sample_config)
          expect(described_class).to receive(:load_yml).with("config/#{base_file}", env).and_return(base_sample_config)
          expect(described_class).to receive(:load_yml).with("config/#{base_file}.example", 'defaults').and_return(nil)
          expect(described_class).to receive(:load_yml).with("config/#{base_file}", 'defaults').and_return(nil)
          described_class.load
        end

        its(:app_url) { should_not be_nil }
        its(:api_key) { should == 'base1234' }
        specify {
          expect { subject.page_title }.to raise_error(described_class::NoSuchConfigurationVariable)
        }
        specify {
          expect { subject.app_host }.to raise_error(described_class::NoSuchConfigurationVariable)
        }
      end

      context 'with different data' do
        before do
          expect(described_class).to receive(:load_yml).with("config/#{base_file}.example", env).and_return(base_sample_config)
          expect(described_class).to receive(:load_yml).with("config/#{base_file}", env).and_return(local_sample_config)
          expect(described_class).to receive(:load_yml).with("config/#{base_file}.example", 'defaults').and_return(nil)
          expect(described_class).to receive(:load_yml).with("config/#{base_file}", 'defaults').and_return(nil)
        end
        it 'raises expection'  do
          expect {
            described_class.load
          }.to raise_error(described_class::MissingConfigurationVariables)
        end
      end
    end

    context 'when extra file is loaded' do
      before do
        expect(described_class).to receive(:load_yml).with("config/#{extra_file}.example", env).and_return(base_sample_config)
        expect(described_class).to receive(:load_yml).with("config/#{extra_file}", env).and_return(nil)
        expect(described_class).to receive(:load_yml).with("config/#{extra_file}.example", 'defaults').and_return(base_default_config)
        expect(described_class).to receive(:load_yml).with("config/#{extra_file}", 'defaults').and_return(nil)

        expect(described_class).to receive(:verify!).never
        described_class.load('mongo.yml')
      end

      it { expect(subject.mongo).to be_kind_of(A9n::Struct) }
      it { expect(subject.instance_variable_get("@mongo")).to be_kind_of(A9n::Struct) }
      it { expect(subject.mongo.app_url).to eq("http://127.0.0.1:3000") }
      it { expect(subject.mongo.page_title).to eq('Base Kielbasa') }
      it { expect(subject.mongo.api_key).to eq('base1234') }
      specify {
        expect { subject.mongo.app_host }.to raise_error(described_class::NoSuchConfigurationVariable)
      }
    end
  end

  describe '.load_yml' do
    let(:root) { File.dirname(__FILE__) }
    let(:env) { 'test' }
    subject {  described_class.load_yml(file_path, env) }

    before do
      expect(described_class).to receive(:root).at_least(:once).and_return(root)
      expect(described_class).to receive(:env).never
    end

    context 'when file not exists' do
      let(:file_path) { 'file_not_existing_in_universe.yml' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when file exists' do
      let(:file_path) { 'fixtures/configuration.yml'}
      before {
        ENV['DWARF'] = 'erbized dwarf'
      }

      context 'and has data' do
        it 'returns non-empty hash' do
          expect(subject).to be_kind_of(Hash)
          expect(subject.keys).to_not be_empty
        end

        it 'has symbolized keys' do
          subject.keys.first.should be_kind_of(Symbol)
          subject[:hash_dwarf].should be_kind_of(Hash)
          subject[:hash_dwarf].keys.first.should be_kind_of(Symbol)
        end

        it 'parses erb' do
          subject[:erb_dwarf].should == 'erbized dwarf'
        end
      end

      context 'and has no data' do
        let(:env) { 'production' }
        it { should be_nil }
      end
    end
  end

  describe '.env' do
    before {
      described_class.instance_variable_set(:@env, nil)
    }

    context 'local_app_env is set' do
      before {
        expect(described_class).to receive(:local_app).and_return(double(env: 'dwarf_env')).exactly(3).times
        expect(described_class).to receive(:get_env_var).never
      }
      its(:env) { should == 'dwarf_env' }
    end

    context "when APP_ENV is set" do
      before {
        expect(described_class).to receive(:local_app_env).and_return(nil)
        expect(described_class).to receive(:get_env_var).with('RAILS_ENV').and_return(nil)
        expect(described_class).to receive(:get_env_var).with('RACK_ENV').and_return(nil)
        expect(described_class).to receive(:get_env_var).with('APP_ENV').and_return('dwarf_env')
      }
      its(:env) { should == 'dwarf_env' }
    end
  end

  describe '.get_env_var' do
    before { ENV['DWARF'] = 'little dwarf' }
    it { described_class.get_env_var('DWARF').should == 'little dwarf'}
    it { described_class.get_env_var('IS_DWARF').should be_nil}
  end

  describe '.get_rails' do
    context 'when defined' do
      before {
        Object.const_set(:Rails, Module.new)
      }
      after {
        Object.send(:remove_const, :Rails)
      }
      it {
        described_class.get_rails.should be_kind_of(Module)
      }
    end
    context 'when not defined' do
      it { described_class.get_rails.should be_nil }
    end
  end

  describe '.var_name_for' do
    it { described_class.var_name_for(:configuration).should == :@configuration }
    it { described_class.var_name_for('configuration.yml').should == :@configuration }
    it { described_class.var_name_for('custom_dir/extra.yml').should == :@extra }
  end
end
