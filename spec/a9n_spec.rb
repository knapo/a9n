require 'spec_helper'

describe A9n do
  describe '.local_app' do
    context 'when no rails found' do
      it 'raises error' do
        expect {
          described_class.local_app
        }.to raise_error(NameError, 'uninitialized constant Module::Rails')
      end
    end
    
    context 'when custom non-rails app is being used' do
      let(:local_app) { stub(:env => 'test', :root => 'local_app') }
      before { described_class.local_app = local_app }

      specify { described_class.local_app.should == local_app }
    end

    after { described_class.local_app = nil }
  end
    
  describe '.load' do
    let(:base_sample_config){
      { :app_url => 'http://127.0.0.1:3000' }
    }
    let(:local_sample_config){
      { :app_host => '127.0.0.1:3000' }
    }
    subject { described_class.cfg }

    context 'when no configuration file exists' do
      before do
        described_class.should_receive(:load_yml).with('config/configuration.yml.example').and_return(nil)
        described_class.should_receive(:load_yml).with('config/configuration.yml').and_return(nil)
        described_class.should_receive(:verify!).never
      end
      it 'raises expection'  do
        lambda {
          described_class.load
        }.should raise_error(described_class::MissingConfigurationFile)
      end
    end
    
    context 'when base configuration file exists' do
      before do
        described_class.should_receive(:load_yml).with('config/configuration.yml.example').and_return(base_sample_config)
        described_class.should_receive(:load_yml).with('config/configuration.yml').and_return(nil)
        described_class.should_receive(:verify!).never
        described_class.load
      end
      it { should_not be_nil }
      its(:app_url) { should_not be_nil }
      specify {
        expect { subject.app_host }.to raise_error(described_class::NoSuchConfigurationVariable)
      }
    end

    context 'when local configuration file exists' do
      before do
        described_class.should_receive(:load_yml).with('config/configuration.yml.example').and_return(nil)
        described_class.should_receive(:load_yml).with('config/configuration.yml').and_return(local_sample_config)
        described_class.should_receive(:verify!).never
        described_class.load
      end

      it { should_not be_nil }
      its(:app_host) { should_not be_nil }
      specify {
        expect { subject.app_url }.to raise_error(described_class::NoSuchConfigurationVariable)
      }
    end

    context 'when both local and base configuration file exists' do
      context 'with same data' do
        before do
          described_class.should_receive(:load_yml).with('config/configuration.yml.example').and_return(base_sample_config)
          described_class.should_receive(:load_yml).with('config/configuration.yml').and_return(base_sample_config)
          described_class.load
        end
        it { should_not be_nil }
        its(:app_url) { should_not be_nil }
        specify {
          expect { subject.app_host }.to raise_error(described_class::NoSuchConfigurationVariable)
        }
      end

      context 'with different data' do
        before do
          described_class.should_receive(:load_yml).with('config/configuration.yml.example').and_return(base_sample_config)
          described_class.should_receive(:load_yml).with('config/configuration.yml').and_return(local_sample_config)
        end
        it 'raises expection'  do
          expect {
            described_class.load
          }.to raise_error(described_class::MissingConfigurationVariables)
        end
      end
    end
  end

  describe '.load_yml' do
    let(:root) { File.dirname(__FILE__) }
    subject {  described_class.load_yml(file_path) }

    before do
      described_class.should_receive(:local_app).at_least(:once).and_return(stub(:root => root))
    end

    context 'when file not exists' do
      before { described_class.should_receive(:env).never }
      let(:file_path) { 'file_not_existing_in_universe.yml' }
      
      it 'returns nil' do
        subject.should be_nil
      end
    end

    context 'when file exists' do
      let(:file_path) { 'fixtures/configuration.yml'}
      before { described_class.should_receive(:env).twice.and_return(env) }

      context 'and has data' do
        let(:env) { 'test' }

        it 'returns non-empty hash' do
          subject.should be_kind_of(Hash)
          subject.keys.should_not be_empty
        end
      end
      context 'and has no data' do
        let(:env) { 'production' }

        it 'raises expection'  do
          expect {
            subject
          }.to raise_error(described_class::MissingConfigurationData)
        end
      end
    end
  end
end