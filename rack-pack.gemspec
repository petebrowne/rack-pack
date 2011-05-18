# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack/pack/version', __FILE__)
require 'bundler'

Gem::Specification.new do |s|
  s.name        = 'rack-pack'
  s.version     = Rack::Pack::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = 'Pete Browne'
  s.email       = 'me@petebrowne.com'
  s.homepage    = 'http://github.com/petebrowne/rack-pack'
  s.summary     = 'Rack Middleware for packaging assets such as javascripts and stylesheets.'
  s.description = 'Rack::Pack is a piece of Rack Middleware that packages and optionally compresses assets such as javascripts and stylesheets into single files. In a development environment, assets will be packaged on each request if there have been changes to the source files. In a production environment, assets will only be packaged one time, and only if there have been changes.'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'rack-pack'

  s.add_dependency             'rack',             '~> 1.2.1'
  s.add_development_dependency 'rspec',            '~> 2.6.0'
  s.add_development_dependency 'activesupport',    '~> 3.0.7'
  s.add_development_dependency 'i18n',             '~> 0.5.0'
  s.add_development_dependency 'test-construct',   '~> 1.2.0'
  s.add_development_dependency 'jsmin',            '~> 1.0.1'
  s.add_development_dependency 'packr',            '~> 3.1.0'
  s.add_development_dependency 'yui-compressor',   '~> 0.9.1'
  s.add_development_dependency 'closure-compiler', '~> 0.3.2'
  s.add_development_dependency 'rainpress',        '~> 1.0.0'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{ |f| f =~ /^bin\/(.*)/ ? $1 : nil }.compact
  s.require_path = 'lib'
end
