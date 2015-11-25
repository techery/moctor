# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moctor/version'

Gem::Specification.new do |spec|
  spec.name          = "moctor"
  spec.version       = Moctor::VERSION
  spec.authors       = ['Serhij Korochanskyj', 'Sergey Zenchenko']
  spec.email         = %w(serge.k@techery.io serge.z@techery.io)

  spec.summary       = 'Immutabler replacement'
  spec.description   = 'Immutabler replacement'
  spec.homepage      = 'https://github.com/techery/moctor'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec'
end
