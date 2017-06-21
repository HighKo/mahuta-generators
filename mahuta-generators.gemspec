# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mahuta/generators/version'

Gem::Specification.new do |spec|
  spec.name          = 'mahuta-generators'
  spec.version       = Mahuta::Generators::VERSION
  spec.authors       = ['Max Trense']
  spec.email         = ['dev@trense.info']

  spec.summary       = %q{Some generator helpers for mahuta}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://mtrense.github.com'

  spec.files         = Dir[*%W'exe/* lib/**/*.rb Gemfile *.gemspec CODE_OF_CONDUCT.* README.* VERSION']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  
  # spec.add_dependency 'cite'
  spec.add_dependency 'diff-lcs', '~> 1.3'
  spec.add_dependency 'diffy', '~> 3.2'
  spec.add_dependency 'tty-prompt'
  spec.add_dependency 'pastel'
  spec.add_dependency 'activesupport', '~> 5.1'
  
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
