require "spec_helper"

describe A9n::Loader do
  let(:env) { "test" }
  let(:root) { File.expand_path("../../../test_app", __FILE__) }
  let(:file_path) { File.join(root, "config/configuration.yml") }
  subject { described_class.new(file_path, env) }

  describe "#intialize" do
    it { expect(subject.env).to eq(env) }
    it { expect(subject.local_file).to eq(file_path) }
    it { expect(subject.example_file).to eq("#{file_path}.example") }
  end

  describe "#load" do
    let(:example_config) {
      { app_url: "http://127.0.0.1:3000", api_key: "example1234" }
    }
    let(:local_config) {
      { app_host: "127.0.0.1:3000", api_key: "local1234" }
    }
    let(:env){
      "tropical"
    }
    let(:config) { subject.get }

    context "when no configuration file exists" do
      before do
        expect(described_class).to receive(:load_yml).with(subject.example_file, env).and_return(nil)
        expect(described_class).to receive(:load_yml).with(subject.local_file, env).and_return(nil)
        expect(subject).to receive(:verify!).never
      end

      it "raises expection"  do
        expect {
          subject.load
        }.to raise_error(A9n::MissingConfigurationData)
      end
    end

    context "when only example configuration file exists" do
      before do
        expect(described_class).to receive(:load_yml).with(subject.example_file, env).and_return(example_config)
        expect(described_class).to receive(:load_yml).with(subject.local_file, env).and_return(nil)
        expect(described_class).to receive(:verify!).never
        subject.load
      end

      it { expect(config.app_url).to eq("http://127.0.0.1:3000") }
      it { expect(config.api_key).to eq("example1234") }

      it do
        expect { config.app_host }.to raise_error(A9n::NoSuchConfigurationVariable)
      end
    end

    context "when only local configuration file exists" do
      before do
        expect(described_class).to receive(:load_yml).with(subject.example_file, env).and_return(nil)
        expect(described_class).to receive(:load_yml).with(subject.local_file, env).and_return(local_config)
        expect(described_class).to receive(:verify!).never
        subject.load
      end

      it { expect(config.app_host).to eq("127.0.0.1:3000") }
      it { expect(config.api_key).to eq("local1234") }

      it do
        expect { config.app_url }.to raise_error(A9n::NoSuchConfigurationVariable)
      end
    end

    context "when both local and base configuration file exists without defaults" do
      context "with same data" do
        before do
          expect(described_class).to receive(:load_yml).with(subject.example_file, env).and_return(example_config)
          expect(described_class).to receive(:load_yml).with(subject.local_file, env).and_return(example_config)
          subject.load
        end

        it { expect(config.app_url).to eq("http://127.0.0.1:3000") }
        it { expect(config.api_key).to eq("example1234") }

        it do
          expect { config.app_host }.to raise_error(A9n::NoSuchConfigurationVariable)
        end
      end

      context "with different data" do
        before do
          expect(described_class).to receive(:load_yml).with(subject.example_file, env).and_return(example_config)
          expect(described_class).to receive(:load_yml).with(subject.local_file, env).and_return(local_config)
        end

        let(:missing_variables_names) { example_config.keys - local_config.keys }

        it "raises expection with missing variables names"  do
          expect {
            subject.load
          }.to raise_error(A9n::MissingConfigurationVariables, /#{missing_variables_names.join(", ")}/)
        end
      end
    end
  end

  describe ".load_yml" do
    let(:env) { "test" }
    subject {  described_class.load_yml(file_path, env) }

    context "when file not exists" do
      let(:file_path) { "file_not_existing_in_the_universe.yml" }

      it{ expect(subject).to be_nil }
    end

    context "when file exists" do
      shared_examples "non-empty config file" do
        it "returns non-empty hash" do
          expect(subject).to be_kind_of(Hash)
          expect(subject.keys).to_not be_empty
        end
      end

      before do
        ENV["DWARF"] = "erbized dwarf"
      end

      context "when file has erb extension" do
        let(:file_path) { File.join(root, "config/a9n/cloud.yml.erb") }

        it_behaves_like "non-empty config file"
      end

      context "having env and defaults data" do
        let(:file_path) { File.join(root, "config/configuration.yml") }

        it_behaves_like "non-empty config file"

        it "contains keys from defaults scope" do
          expect(subject[:default_dwarf]).to eq("default dwarf")
          expect(subject[:overriden_dwarf]).to eq("already overriden dwarf")
        end

        it "has symbolized keys" do
          expect(subject.keys.first).to be_kind_of(Symbol)
          expect(subject[:hash_dwarf]).to be_kind_of(Hash)
          expect(subject[:hash_dwarf].keys.first).to be_kind_of(Symbol)
        end

        it "parses erb" do
          expect(subject[:erb_dwarf]).to eq("erbized dwarf")
        end
      end

      context "having no env and only defaults data" do
        let(:file_path) { File.join(root, "config/configuration.yml") }
        let(:env) { "production" }

        it_behaves_like "non-empty config file"

        it "contains keys from defaults scope" do
          expect(subject[:default_dwarf]).to eq("default dwarf")
          expect(subject[:overriden_dwarf]).to eq("not yet overriden dwarf")
        end
      end

      context "having only env and no default data" do
        let(:file_path) { File.join(root, "config/no_defaults.yml") }

        context "valid env" do
          let(:env) { "production" }
          it_behaves_like "non-empty config file"
        end

        context "invalid env" do
          let(:env) { "tropical" }
          it { expect(subject).to be_nil }
        end
      end
    end
  end
end
