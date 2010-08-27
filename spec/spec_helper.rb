lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'rspec'
require 'construct'
require 'jsmin'
require 'packr'
require 'yui/compressor'
# To get 2.weeks.ago syntax...
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/numeric/time'
require 'rack/pack'

$hidden_consts = {}
[ :JSMin, :Packr, :YUI ].each do |const|
  $hidden_consts[const] = Object.const_get(const)
  Object.send :remove_const, const
end

RSpec.configure do |config|
  config.include Construct::Helpers
  
  def reveal_const(const)
    Object.const_set const, $hidden_consts[const]
    yield
    Object.send :remove_const, const
  end
end
