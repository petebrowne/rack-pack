# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack/pack/version', __FILE__)
require 'bundler'

Gem::Specification.new do |s|
  s.name        = 'rack-pack'
  s.version     = Rack::Pack::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = 'Pete Browne'
  s.email       = 'me@petebrowne.com'
  s.homepage    = 'http://rubygems.org/gems/rack-pack'
  s.summary     = 'Rack Middleware for packaging assets such as javascripts and stylesheets.'
  s.description = 'Packages assets such as javascripts and stylesheets using a method inspired by Sass::Plugin. In development mode, the assets are packaged on each request. In production mode, the assets are packaged only one time.'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'rack-pack'

  s.add_dependency             'rack',             '~> 1.2.1'
  s.add_development_dependency 'rspec',            '~> 2.0.0.beta.20'
  s.add_development_dependency 'activesupport',    '~> 3.0.0.rc2'
  s.add_development_dependency 'test-construct',   '~> 1.2.0'
  s.add_development_dependency 'jsmin',            '~> 1.0.1'
  s.add_development_dependency 'packr',            '~> 3.1.0'
  s.add_development_dependency 'yui-compressor',   '~> 0.9.1'
  s.add_development_dependency 'closure-compiler', '~> 0.3.2'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{ |f| f =~ /^bin\/(.*)/ ? $1 : nil }.compact
  s.require_path = 'lib'
end
