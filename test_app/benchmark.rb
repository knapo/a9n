require 'rubygems'
require 'bundler/setup'
require 'benchmark'
require 'a9n'

class SampleBenchmarkApp
  def run
    0.upto(1_000).map do |index|
      "#{index} #{::A9n.string_dwarf} #{::A9n.overriden_dwarf}"
    end
  end

  def root
    Pathname.new('./test_app').expand_path
  end

  def env
    :test
  end
end

A9n.app = SampleBenchmarkApp.new
results = []

(1..10).each do
  results << Benchmark.realtime { A9n.app.run }
end

puts (results.reduce(&:+) / 10).round(4)
