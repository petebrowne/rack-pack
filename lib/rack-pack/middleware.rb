module Rack
  module Pack
    class Middleware
      attr_reader :packs
      
      def initialize(app, options = {})
        @app     = app
        @packs   = {}
        @options = options.reverse_merge(
          :public_dir => './public',
          :app_dir    => Object.const_defined?(:Rails) ? './app' : '.'
        )
        
        add_pack 'javascripts/application.js',  ::File.join(@options[:app_dir], 'javascripts/**/*.js')
        add_pack 'stylesheets/application.css', ::File.join(@options[:app_dir], 'stylesheets/**/*.css')
      end
      
      def call(env)
        @packs.each_value do |pack|
          pack.update if pack.stale?
        end
        @app.call(env)
      end
      
      def add_pack(to_file, from_files, options = {})
        public_to_file  = ::File.join(@options[:public_dir], to_file.to_s)
        @packs[to_file] = Rack::Pack::Packer.new(public_to_file, from_files, options)
      end
    end
  end
end