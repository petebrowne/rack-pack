require 'rack'

module Rack
  module Pack
    autoload :Packer,     'rack-pack/packer'
    autoload :Middleware, 'rack-pack/middleware'
    autoload :Version,    'rack-pack/version'
    
    class << self
      def new(*args)
        Rack::Pack::Middleware.new(*args)
      end
    end
  end
end
