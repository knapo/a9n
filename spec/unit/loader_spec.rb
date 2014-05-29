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
    let(:example_env_config) {
      { app_url: "http://127.0.0.1:3000", api_key: "base1234" }
    }
    let(:local_env_config) {
      { app_host: "127.0.0.1:3000", api_key: "local1234" }
    }
    let(:example_default_config) {
      { page_title: "Base Kielbasa", api_key: "example1234default"  }
    }
    let(:local_default_config) {
      { page_title: "Local Kielbasa", api_key: "local1234default" }
    }
    let(:env){
      "tropical"
    }
    let(:config) { subject.get }

    context "when no configuration file exists" do
      before do
        expect(described_class).to receive(:load_yml).with(subject.example_file, env).and_return(nil)
        expect(described_class).to receive(:load_yml).with(subject.local_file, env).and_return(nil)
        expect(described_class).to receive(:load_yml).with(subject.example_file, "defaults").and_return(nil)
        expect(described_class).to receive(:load_yml).with(subject.local_file, "defaults").and_return(nil)
        expect(subject).to receive(:verify!).never
      end
      it "raises expection"  do
        expect {
          subject.load
        }.to raise_error(A9n::MissingConfigurationData)
      end
    end

    context "when example configuration file exists with defaults" do
      before do
        expect(described_class).to receive(:load_yml).with(subject.example_file, env).and_return(example_env_config)
        expect(described_class).to receive(:load_yml).with(subject.local_file, env).and_return(nil)
        expect(described_class).to receive(:load_yml).with(subject.example_file, "defaults").and_return(example_default_config)
        expect(described_class).to receive(:load_yml).with(subject.local_file, "defaults").and_return(nil)

        expect(described_class).to receive(:verify!).never
        subject.load
      end

      it { expect(config.app_url).to eq("http://127.0.0.1:3000") }
      it { expect(config.page_title).to eq("Base Kielbasa") }
      it { expect(config.api_key).to eq("base1234") }

      it {
        expect { config.app_host }.to raise_error(A9n::NoSuchConfigurationVariable)
      }
    end

    context "when local configuration file exists with defaults" do
      before do
        expect(described_class).to receive(:load_yml).with(subject.example_file, env).and_return(nil)
        expect(described_class).to receive(:load_yml).with(subject.local_file, env).and_return(local_env_config)
        expect(described_class).to receive(:load_yml).with(subject.example_file, "defaults").and_return(nil)
        expect(described_class).to receive(:load_yml).with(subject.local_file, "defaults").and_return(local_default_config)
        expect(described_class).to receive(:verify!).never
        subject.load
      end
      it { expect(config.app_host).to eq("127.0.0.1:3000") }
      it { expect(config.page_title).to eq("Local Kielbasa") }
      it { expect(config.api_key).to eq("local1234") }

      it {
        expect { config.app_url }.to raise_error(A9n::NoSuchConfigurationVariable)
      }
    end

    context "when both local and base configuration file exists without defaults" do
      context "with same data" do
        before do
          expect(described_class).to receive(:load_yml).with(subject.example_file, env).and_return(example_env_config)
          expect(described_class).to receive(:load_yml).with(subject.local_file, env).and_return(example_env_config)
          expect(described_class).to receive(:load_yml).with(subject.example_file, "defaults").and_return(nil)
          expect(described_class).to receive(:load_yml).with(subject.local_file, "defaults").and_return(nil)
          subject.load
        end

        it { expect(config.app_url).to eq("http://127.0.0.1:3000") }
        it { expect(config.api_key).to eq("base1234") }

        it {
          expect { config.page_title }.to raise_error(A9n::NoSuchConfigurationVariable)
        }
        it {
          expect { config.app_host }.to raise_error(A9n::NoSuchConfigurationVariable)
        }
      end

      context "with different data" do
        before do
          expect(described_class).to receive(:load_yml).with(subject.example_file, env).and_return(example_env_config)
          expect(described_class).to receive(:load_yml).with(subject.local_file, env).and_return(local_env_config)
          expect(described_class).to receive(:load_yml).with(subject.example_file, "defaults").and_return(nil)
          expect(described_class).to receive(:load_yml).with(subject.local_file, "defaults").and_return(nil)
        end
        it "raises expection"  do
          expect {
            subject.load
          }.to raise_error(A9n::MissingConfigurationVariables)
        end
      end
    end
  end

  describe ".load_yml" do
    let(:env) { "test" }
    subject {  described_class.load_yml(file_path, env) }

    context "when file not exists" do
      let(:file_path) { "file_not_existing_in_universe.yml" }

      it{ expect(subject).to be_nil }
    end

    context "when file exists" do
      let(:file_path) { File.join(root, "config/configuration.yml") }

      before {
        ENV["DWARF"] = "erbized dwarf"
      }

      context "and has data" do
        it "returns non-empty hash" do
          expect(subject).to be_kind_of(Hash)
          expect(subject.keys).to_not be_empty
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

      context "and has no data" do
        let(:env) { "production" }
        it{ expect(subject).to be_nil }
      end
    end
  end
end
