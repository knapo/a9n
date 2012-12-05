require 'spec_helper'

describe A9n::Store do
  subject { described_class.new(:app_host => 'http://127.0.0.1:3000') }

  it 'gets value' do
    subject.app_host.should == 'http://127.0.0.1:3000'
  end

  it 'raises exception when value not exists' do
    expect { 
      subject.non_existing
    }.to raise_error(A9n::NoSuchConfigurationVariable)
  end
end