lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'fileutils'
require 'rspec'
require 'construct'
# To get 2.weeks.ago syntax...
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/numeric/time'
require 'jsmin'
require 'packr'
require 'yui/compressor'
require 'closure-compiler'
require 'uglifier'
require 'rainpress'
require 'rack/pack'

$hidden_consts = {}
[ :JSMin, :Packr, :YUI, :Closure, :Uglifier, :Rainpress ].each do |const|
  $hidden_consts[const] = Object.const_get(const)
  Object.send :remove_const, const
end

RSpec.configure do |config|
  config.include Construct::Helpers
  
  config.after do
    Rack::Pack.packages    = nil
    Rack::Pack.options     = nil
    Rack::Pack.environment = nil
  end
  
  def reveal_const(const)
    begin
      Object.const_set const, $hidden_consts[const]
      yield
    ensure
      Object.send :remove_const, const
    end
  end
end
