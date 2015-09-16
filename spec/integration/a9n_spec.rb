RSpec.describe A9n do
  subject { described_class }

  let(:env) { "test" }

  before do
    clean_singleton(subject)
    subject.app = double(env: env)
    subject.root = File.expand_path("../../../test_app", __FILE__)
    subject.load
  end

  after do
    clean_singleton(subject)
  end

  context "base config file" do
    it do
      expect(subject.storage).to be_kind_of(A9n::Struct)
    end

    it do
      expect(subject.default_dwarf).to eq("default dwarf")
      expect(subject.overriden_dwarf).to eq("already overriden dwarf")
    end

    it do
      expect(subject.fetch(:default_dwarf)).to eq("default dwarf")
      expect(subject.fetch(:overriden_dwarf)).to eq("already overriden dwarf")
    end

    it do
      expect { subject.invalid }.to raise_error(A9n::NoSuchConfigurationVariable)
    end

    it do
      expect { subject.fetch(:invalid) }.to raise_error(::KeyError)
    end

    it do
      expect { subject.fetch(:invalid, "Hello").to eq("Hello") }
    end
  end

  context "undefined env" do
    let(:env) { "tropical" }

    it do
      expect(subject.default_dwarf).to eq("default dwarf")
      expect(subject.overriden_dwarf).to eq("not yet overriden dwarf")
    end

    it do
      expect(subject.fetch(:default_dwarf)).to eq("default dwarf")
      expect(subject.fetch(:overriden_dwarf)).to eq("not yet overriden dwarf")
    end
  end

  context "extra config file" do
    before do
      expect(subject.mandrill).to be_kind_of(A9n::Struct)
    end

    it do
      expect(subject.mandrill.username).to eq("joe")
      expect(subject.mandrill.api_key).to eq("asdf1234")
    end

    it do
      expect(subject.mandrill.fetch(:username)).to eq("joe")
      expect(subject.mandrill.fetch(:api_key)).to eq("asdf1234")
    end

    it do
      expect(subject.fetch(:mandrill)).to eq(subject.mandrill)
    end
  end

  context "extra config file with erb" do
    before do
      expect(subject.cloud).to be_kind_of(A9n::Struct)
    end

    it do
      expect(subject.cloud.username).to eq("testuser")
      expect(subject.cloud.password).to eq("qwerty")
    end

    it do
      expect(subject.cloud.fetch(:username)).to eq("testuser")
      expect(subject.cloud.fetch(:password)).to eq("qwerty")
    end

    it do
      expect(subject.fetch(:cloud)).to eq(subject.cloud)
    end
  end

  context "extra config file with example" do
    before do
      expect(subject.mailer).to be_kind_of(A9n::Struct)
    end

    it do
      expect(subject.mailer.delivery_method).to eq("test")
    end

    it do
      expect(subject.mailer.fetch(:delivery_method)).to eq("test")
    end

    it do
      expect(subject.fetch(:mailer)).to eq(subject.mailer)
    end
  end
end
