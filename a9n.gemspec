require File.expand_path('../lib/a9n/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Krzysztof Knapik"]
  gem.email         = ["knapo@knapo.net"]
  gem.description   = %q{a9n - ruby/rails apps configuration manager}
  gem.summary       = %q{a9n is a tool to keep ruby/rails apps extra configuration easily maintainable and verifiable}
  gem.homepage      = "https://github.com/knapo/a9n"
  gem.license       = 'MIT'
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "a9n"
  gem.require_paths = ["lib"]
  gem.version       = A9n::VERSION

  gem.required_ruby_version = ">= 2.2"

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'codeclimate-test-reporter'
  gem.add_development_dependency 'pry'
end
