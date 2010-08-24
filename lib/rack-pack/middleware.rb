module Rack
  module Pack
    class Middleware
      DEFAULT_OPTIONS = {
        :public_dir => 'public'
      }.freeze
      
      def initialize(app, options = {})
        @app      = app
        @packages = {}
        @options  = DEFAULT_OPTIONS.dup
        
        @options.each_key do |key|
          @options[key] = options.delete(key) if options.key?(key)
        end
        
        add_package 'javascripts/application.js',  "{vendor,app,.}/{javascripts,js}/**/*.js"
        add_package 'stylesheets/application.css', "{vendor,app,.}/{stylesheets,css}/**/*.css"
        
        options.each do |to_file, from_files|
          add_package(to_file, from_files)
        end
      end
      
      def call(env)
        update_packages
        @app.call(env)
      end
      
      def add_package(to_file, from_files)
        public_to_file     = ::File.join(@options[:public_dir], to_file.to_s)
        @packages[to_file] = Rack::Pack::Package.new(public_to_file, from_files)
      end
      
      protected
      
      def update_packages
        @packages.each_value do |package|
          package.update if package.stale?
        end
      end
    end
  end
end