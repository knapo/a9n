require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

require 'rubocop/rake_task'
RuboCop::RakeTask.new

desc 'Run all specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = './spec/**/*_spec.rb'
  t.rspec_opts = ['--profile', '--color']
end

task default: [:spec, :rubocop]
