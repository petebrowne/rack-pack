module Rack
  module Pack
    module Packages
      class Javascript < Rack::Pack::Package
        def compile
          compiled = super
          if defined?(JSMin)
            JSMin.minify(compiled).strip
          elsif defined?(Packr)
            Packr.pack(compiled, :shrink_vars => true).strip
          else
            compiled.strip
          end
        end
      end
    end
  end
end
