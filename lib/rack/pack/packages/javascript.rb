module Rack
  module Pack
    module Packages
      class Javascript < Rack::Pack::Package
        def compile
          compiled = super
          if defined?(JSMin)
            JSMin.minify(compiled).strip
          elsif defined?(Packr)
            options = compression_options :shrink_vars => true
            Packr.pack(compiled, options).strip
          else
            compiled.strip
          end
        end
        
        protected
        
        def compression_options(defaults = {})
          return defaults unless Rack::Pack::Middleware.options
          defaults.merge Rack::Pack::Middleware.options[:js_compression]
        end
      end
    end
  end
end
