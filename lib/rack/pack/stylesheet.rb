module Rack
  class Pack
    class Stylesheet < Package
      def compress(source)
        if defined?(YUI) and defined?(YUI::CssCompressor)
          YUI::CssCompressor.new(compression_options).compress(source)
        else
          string
        end
      end
      
      protected
      
      def compression_options(defaults = {})
        return defaults unless Pack.options
        defaults.merge Pack.options[:css_compression]
      end
    end
  end
end
