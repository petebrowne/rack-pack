# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rack-pack/version'
require 'bundler'

Gem::Specification.new do |s|
  s.name        = 'rack-pack'
  s.version     = Rack::Pack::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = 'Pete Browne'
  s.email       = 'me@petebrowne.com'
  s.homepage    = 'http://rubygems.org/gems/rack-pack'
  s.summary     = 'TODO: Write a gem summary'
  s.description = 'TODO: Write a gem description'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'rack-pack'
  
  s.add_bundler_dependencies

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{ |f| f =~ /^bin/ }
  s.require_path = 'lib'
end
