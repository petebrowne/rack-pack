module Rack
  class Pack
    class Javascript < Package
      def compile
        compiled = super
        compiled = compress(compiled) if compress?
        compiled.strip
      end
      
      protected
      
      def compress(string)
        if defined?(JSMin)
          JSMin.minify(string)
        elsif defined?(Packr)
          options = compression_options :shrink_vars => true
          Packr.pack(string, options)
        elsif defined?(YUI) and defined?(YUI::JavaScriptCompressor)
          options = compression_options :munge => true
          YUI::JavaScriptCompressor.new(options).compress(string)
        elsif defined?(Closure) and defined?(Closure::Compiler)
          Closure::Compiler.new(compression_options).compile(string)
        else
          string
        end
      end
      
      def compression_options(defaults = {})
        return defaults unless Pack.options
        defaults.merge Pack.options[:js_compression]
      end
    end
  end
end
