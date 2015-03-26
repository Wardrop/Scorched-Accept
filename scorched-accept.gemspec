$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

Gem::Specification.new 'scorched-accept', '0.1' do |s|
  s.summary           = 'HTTP accept header parser'
  s.description       = 'A parser for parsing the accept headers of a HTTP request'
  s.authors           = ['Tom Wardrop']
  s.email             = 'tom@tomwardrop.com'
  s.homepage          = 'http://github.com/wardrop/acceptable'
  s.license           = 'MIT'
  s.files             = Dir.glob(`git ls-files`.split("\n") - %w[.gitignore])
  s.test_files        = Dir.glob('spec/**/*_spec.rb')
  s.rdoc_options      = %w[--line-numbers --inline-source --title Rack::Accept --encoding=UTF-8]

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'parslet', '~> 1.6'
  s.add_development_dependency 'rack-test', '~> 0.6'
  s.add_development_dependency 'maxitest'
end
