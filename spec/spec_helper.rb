require "simplecov"
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start

require "rubygems"
require "bundler/setup"

require "a9n"

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
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
