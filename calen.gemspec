# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'calen/version'

Gem::Specification.new do |spec|
  spec.name          = 'calen'
  spec.version       = Calen::VERSION
  spec.authors       = ['David Bruce']
  spec.email         = ['djb@ragnarok.net']
  spec.description   = 'Find a free meeting room'
  spec.summary       = 'Find a free meeting room'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-rescue'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'vcr'
  spec.add_dependency 'chronic'
  spec.add_dependency 'chronic_duration'
end
