require 'rack'

module Rack
  module Pack
    autoload :Package,    'rack/pack/package'
    autoload :Middleware, 'rack/pack/middleware'
    autoload :Version,    'rack/pack/version'
    
    module Packages
      autoload :Javascript, 'rack/pack/packages/javascript'
      autoload :Stylesheet, 'rack/pack/packages/stylesheet'
    end
    
    class << self
      def new(*args)
        Rack::Pack::Middleware.new(*args)
      end
    end
  end
end

Rack::Pack::Package.register :js,  Rack::Pack::Packages::Javascript
Rack::Pack::Package.register :css, Rack::Pack::Packages::Stylesheet
