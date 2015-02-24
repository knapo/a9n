require 'simplecov'
require 'codeclimate-test-reporter'

CodeClimate::TestReporter.start

require 'rubygems'
require 'bundler/setup'

require 'a9n'

RSpec.configure do |config|
  config.expect_with :rspec do |expect_with|
    expect_with.syntax = :expect
  end
  config.order = "random"
  config.tty = true
end

def clean_singleton(klass)
  [:@storage, :@env, :@app, :@root].each do |var|
    if klass.instance_variable_defined?(var)
      klass.remove_instance_variable(var)
    end
  end
end
