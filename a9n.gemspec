require File.expand_path('lib/a9n/version', __dir__)

Gem::Specification.new do |spec|
  spec.name     = 'a9n'
  spec.version  = A9n::VERSION
  spec.authors  = ['Krzysztof Knapik']
  spec.email    = ['knapo@knapo.net']

  spec.summary  = 'a9n - ruby/rails apps configuration manager'
  spec.homepage = 'https://github.com/knapo/a9n'
  spec.license  = 'MIT'

  spec.metadata['homepage_uri'] = 'https://github.com/knapo/a9n'
  spec.metadata['source_code_uri'] = 'https://github.com/knapo/a9n'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(bin/|spec/|test_app/|\.rub)}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
end
