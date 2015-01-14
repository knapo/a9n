require "spec_helper"

describe A9n do
  subject { described_class }

  let(:env) { "test" }

  before {
    subject.app = double(env: env)
    subject.root = File.expand_path("../../../test_app", __FILE__)
  }

  after {
    subject.instance_variable_set(:@env, nil)
    subject.root = nil
    subject.app = nil
  }

  context "base config file" do
    it {
      expect(subject.default_dwarf).to eq("default dwarf")
      expect(subject.overriden_dwarf).to eq("already overriden dwarf")
    }
  end

  context "undefined env" do
    let(:env) { "tropical" }
    it {
      expect(subject.default_dwarf).to eq("default dwarf")
      expect(subject.overriden_dwarf).to eq("not yet overriden dwarf")
    }
  end

  context "extra config file" do
    it {
      expect(subject.mandrill).to be_kind_of(A9n::Struct)
      expect(subject.mandrill.username).to eq("joe")
      expect(subject.mandrill.api_key).to eq("asdf1234")
    }
  end

  context "extra config file with erb" do
    it {
      expect(subject.cloud).to be_kind_of(A9n::Struct)
      expect(subject.cloud.username).to eq("testuser")
      expect(subject.cloud.password).to eq("qwerty")
    }
  end

  context "extra config file with example" do
    it {
      expect(subject.mailer).to be_kind_of(A9n::Struct)
      expect(subject.mailer.delivery_method).to eq("test")
    }
  end
end
