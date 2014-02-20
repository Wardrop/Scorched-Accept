$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rack/acceptable/version'

Gem::Specification.new 'rack-acceptable', Rack::Acceptable::VERSION do |s|
  s.summary           = 'HTTP accept header parser'
  s.description       = 'A parser for parsing the accept headers of a HTTP request'
  s.authors           = ['Tom Wardrop']
  s.email             = 'tom@tomwardrop.com'
  s.homepage          = 'http://github.com/wardrop/rack-acceptable'
  s.license           = 'MIT'
  s.files             = Dir.glob(`git ls-files`.split("\n") - %w[.gitignore])
  s.test_files        = Dir.glob('spec/**/*_spec.rb')
  s.rdoc_options      = %w[--line-numbers --inline-source --title Rack::Acceptable --encoding=UTF-8]

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'treetop', '~> 1.4'
  s.add_development_dependency 'rack-test', '~> 0.6'
  s.add_development_dependency 'rspec', '~> 2.9'
end