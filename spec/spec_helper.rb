require 'rubygems'
require 'bundler/setup'

require 'a9n'

require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.order = "random"
  config.color_enabled = true
  config.tty = true
end