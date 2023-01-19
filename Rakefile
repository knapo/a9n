require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc 'Default task to run on ci'
task ci: %i[spec rubocop]

task default: %i[spec rubocop:autocorrect_all]
