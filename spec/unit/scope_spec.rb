RSpec.describe A9n::Scope do
  subject { described_class.new(name) }

  describe "#name" do
    let(:name) { "configuration" }
    it { expect(subject.name).to eq(:configuration) }
  end

  describe "#main?" do
    context "when name is configuration" do
      let(:name) { "configuration" }
      it { expect(subject).to be_main }
    end

    context "when name is other than configuration" do
      let(:name) { "mandrill" }
      it { expect(subject).not_to be_main }
    end
  end
end
