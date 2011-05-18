module Rack
  class Pack
    class Javascript < Package
      def compress(source)
        if defined?(JSMin)
          JSMin.minify(source)
        elsif defined?(Packr)
          options = compression_options :shrink_vars => true
          Packr.pack(source, options)
        elsif defined?(YUI) and defined?(YUI::JavaScriptCompressor)
          options = compression_options :munge => true
          YUI::JavaScriptCompressor.new(options).compress(source)
        elsif defined?(Closure) and defined?(Closure::Compiler)
          Closure::Compiler.new(compression_options).compile(source)
        elsif defined?(Uglifier)
          Uglifier.new(compression_options).compile(source)
        else
          source
        end
      end
      
      protected
      
        def compression_options(defaults = {})
          return defaults unless Pack.options
          defaults.merge Pack.options[:js_compression]
        end
    end
  end
end
