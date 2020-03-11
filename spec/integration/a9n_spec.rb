RSpec.describe A9n do
  subject { described_class }

  let(:env) { 'test' }

  before do
    clean_singleton(subject)
    ENV['ERB_FOO'] = 'erbized foo'
    ENV['FOO_PASSWORD'] = 'foo123'
    ENV['FOO_KEY'] = 'key123'
    ENV['AWS_API_KEY'] = 'ASDF1234'
    ENV['API_KEY'] = 'XYZ999'
    subject.app = double(env: env)
    subject.root = File.expand_path('../../test_app', __dir__)
    subject.load
  end

  after do
    clean_singleton(subject)
    ENV.delete('ERB_FOO')
    ENV.delete('FOO_PASSWORD')
    ENV.delete('FOO_KEY')
    ENV.delete('AWS_API_KEY')
    ENV.delete('API_KEY')
  end

  context 'base config file' do
    it do
      expect(subject.storage).to be_kind_of(A9n::Struct)
    end

    it do
      expect(subject.default_foo).to eq('default foo')
      expect(subject.overriden_foo).to eq('already overriden foo')
      subject.set(:default_foo, 'lazy foo')
      subject.set(:overriden_foo, 'hard working foo')
      expect(subject.default_foo).to eq('lazy foo')
      expect(subject.overriden_foo).to eq('hard working foo')
      subject.load
      expect(subject.default_foo).to eq('default foo')
      expect(subject.overriden_foo).to eq('already overriden foo')
    end

    it do
      expect(subject.fetch(:default_foo)).to eq('default foo')
      expect(subject.fetch(:overriden_foo)).to eq('already overriden foo')
    end

    it do
      expect { subject.invalid }.to raise_error(A9n::KeyNotFoundError)
    end

    it do
      expect { subject.fetch(:invalid) }.to raise_error(::KeyError)
    end

    it do
      expect { subject.fetch(:invalid, 'Hello').to eq('Hello') }
    end
  end

  context 'undefined env' do
    let(:env) { 'tropical' }

    it do
      expect(subject.default_foo).to eq('default foo')
      expect(subject.overriden_foo).to eq('not yet overriden foo')
    end

    it do
      expect(subject.fetch(:default_foo)).to eq('default foo')
      expect(subject.fetch(:overriden_foo)).to eq('not yet overriden foo')
    end
  end

  context 'extra config file' do
    before do
      expect(subject.aws).to be_kind_of(A9n::Struct)
    end

    it do
      expect(subject.aws.username).to eq('joe')
      expect(subject.aws.api_key).to eq('ASDF1234')
    end

    it do
      expect(subject.aws.fetch(:username)).to eq('joe')
      expect(subject.aws.fetch(:api_key)).to eq('ASDF1234')
    end

    it do
      expect(subject.fetch(:aws)).to eq(subject.aws)
    end
  end

  context 'extra config file with erb' do
    before do
      expect(subject.cloud).to be_kind_of(A9n::Struct)
    end

    it do
      expect(subject.cloud.username).to eq('testuser')
      expect(subject.cloud.password).to eq('qwerty')
    end

    it do
      expect(subject.cloud.fetch(:username)).to eq('testuser')
      expect(subject.cloud.fetch(:password)).to eq('qwerty')
    end

    it do
      expect(subject.fetch(:cloud)).to eq(subject.cloud)
    end
  end

  context 'extra config file with example' do
    before do
      expect(subject.mailer).to be_kind_of(A9n::Struct)
    end

    it do
      expect(subject.mailer.delivery_method).to eq('test')
    end

    it do
      expect(subject.mailer.fetch(:delivery_method)).to eq('test')
    end

    it do
      expect(subject.fetch(:mailer)).to eq(subject.mailer)
    end
  end

  context 'extra config file without known namspaces' do
    before do
      expect(subject.emails).to be_kind_of(A9n::Struct)
    end

    it do
      expect(subject.emails.knapo).to eq('knapo@a9n.local')
      expect(subject.emails.admin).to eq('admin@a9n.local')
      expect { subject.emails.foo }.to raise_error(A9n::KeyNotFoundError)
    end

    it do
      expect(subject.emails.fetch(:knapo)).to eq('knapo@a9n.local')
      expect(subject.emails.fetch(:admin)).to eq('admin@a9n.local')
    end
  end
end
