require "spec_helper"

describe A9n do
  subject { described_class }

  after {
    subject.instance_variable_set(:@storage, nil)
    subject.instance_variable_set(:@env, nil)
    subject.root = nil
    subject.app = nil
  }

  describe ".env" do
    before {
      subject.instance_variable_set(:@env, nil)
    }

    context "app_env is set" do
      before {
        expect(subject).to receive(:app).and_return(double(env: "dwarf_env")).exactly(3).times
        expect(subject).to receive(:get_env_var).never
      }

      it { expect(subject.env).to eq("dwarf_env") }
    end

    context "when APP_ENV is set" do
      before {
        expect(subject).to receive(:app_env).and_return(nil)
        expect(subject).to receive(:get_env_var).with("RAILS_ENV").and_return(nil)
        expect(subject).to receive(:get_env_var).with("RACK_ENV").and_return(nil)
        expect(subject).to receive(:get_env_var).with("APP_ENV").and_return("dwarf_env")
      }

      it { expect(subject.env).to eq("dwarf_env") }
    end
  end

  describe ".app" do
    context "when rails not found" do
      before {
        expect(subject).to receive(:get_rails).and_return(nil)
      }
      specify {
        expect(subject.app).to be_nil
      }
    end

    context "when rails app is being used" do
      let(:app) { double(env: "test", root: "/apps/a9n") }
      before {
        expect(subject).to receive(:get_rails).and_return(app)
      }

      specify { expect(subject.app).to eq(app) }
    end

    context "when custom non-rails app is being used" do
      let(:app) { double(env: "test", root: "/apps/a9n") }
      before { subject.app = app }

      specify { expect(subject.app).to eq(app) }
    end
  end

  describe ".root" do
    let(:app) { double(env: "test", root: "/apps/a9n") }
    before { subject.app = app }

    context "with custom path" do
      before {
        subject.root = "/home/knapo/workspace/a9n"
      }
      specify {
        expect(subject.root).to eq(Pathname.new("/home/knapo/workspace/a9n"))
      }
    end

    context "with local app path" do
      specify {
        expect(subject.root).to eq("/apps/a9n")
      }
    end
  end

  describe ".get_rails" do
    context "when defined" do
      before {
        Object.const_set(:Rails, Module.new)
      }
      after {
        Object.send(:remove_const, :Rails)
      }
      it {
        expect(subject.get_rails).to be_kind_of(Module)
      }
    end
    context "when not defined" do
      it { expect(subject.get_rails).to be_nil }
    end
  end

  describe ".get_env_var" do
    before { ENV["DWARF"] = "little dwarf" }
    it { expect(subject.get_env_var("DWARF")).to eq("little dwarf")}
    it { expect(subject.get_env_var("IS_DWARF")).to be_nil}
  end

  describe ".default_files" do
    before {
      subject.root = File.expand_path("../../../test_app", __FILE__)
    }
    it {
      expect(subject.default_files[0]).to include("configuration.yml")
      expect(Pathname.new(subject.default_files[0])).to be_absolute
      expect(subject.default_files[1]).to include("a9n/mandrill.yml")
      expect(Pathname.new(subject.default_files[1])).to be_absolute
    }
  end

  describe ".load" do
    before {
      expect(described_class).to receive(:env).exactly(2).times.and_return("dev")
      subject.root = "/apps/test_app"
      files.each do |f, cfg|
        expect(A9n::Loader).to receive(:new).with(f, "dev").and_return(double(get: cfg))
      end
    }
    context "when no files given" do
      let(:files) {
        {
          "/apps/test_app/config/file1.yml" => { host: "host1.com" },
          "/apps/test_app/config/dir/file2.yml" => { host: "host2.com" }
        }
      }
      before {
        expect(subject).to receive(:default_files).and_return(files.keys)
        expect(subject).to receive(:get_absolute_paths_for).never
      }
      it {
        expect(subject.load).to eq(files.values)
      }
    end

    context "when custom files given" do
      let(:given_files) {
        ["file3.yml", "/apps/test_app/config/dir/file4.yml"]
      }
      let(:files) {
        {
          "/apps/test_app/config/file3.yml" => { host: "host3.com" },
          "/apps/test_app/config/dir/file4.yml" => { host: "host4.com" }
        }
      }
      before {
        expect(subject).to receive(:default_files).never
        expect(subject).to receive(:get_absolute_paths_for).with(given_files).and_call_original
      }
      it {
        expect(subject.load(*given_files)).to eq(files.values)
      }
    end
  end

  describe ".method_missing" do
    context "when storage is empty" do
      before { expect(subject).to receive(:load).once }
      it {
        expect(subject.storage).to be_empty
        expect { subject.whatever }.to raise_error(A9n::NoSuchConfigurationVariable)
      }
    end

    context "when storage is not empty" do
      before {
        subject.storage[:whenever] = 'whenever'
        expect(subject).not_to receive(:load)
      }
      it {
        expect { subject.whatever }.to raise_error(A9n::NoSuchConfigurationVariable)
      }
    end
  end
end
