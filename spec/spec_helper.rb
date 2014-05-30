require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '/spec/'
end

require 'rubygems'
require 'bundler/setup'

require 'a9n'

RSpec.configure do |config|
  config.expect_with :rspec do |expect_with|
    expect_with.syntax = :expect
  end
  config.order = "random"
  config.color_enabled = true
  config.tty = true
end
