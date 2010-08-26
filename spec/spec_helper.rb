lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'rspec'
require 'construct'
# To get 2.weeks.ago syntax...
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/numeric/time'
require 'rack/pack'

RSpec.configure do |config|
  config.include Construct::Helpers
end
