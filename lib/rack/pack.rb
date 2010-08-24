require 'rack'

module Rack
  module Pack
    autoload :Package,    'rack/pack/package'
    autoload :Middleware, 'rack/pack/middleware'
    autoload :Version,    'rack/pack/version'
    
    class << self
      def new(*args)
        Rack::Pack::Middleware.new(*args)
      end
    end
  end
end
