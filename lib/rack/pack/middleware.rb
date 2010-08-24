module Rack
  module Pack
    class Middleware
      DEFAULT_OPTIONS = {
        :public_dir    => 'public',
        :always_update => false
      }.freeze
      
      def initialize(app, options = {})
        @app      = app
        @packages = {}
        @options  = DEFAULT_OPTIONS.dup
        
        @options.each_key do |key|
          @options[key] = options.delete(key) if options.key?(key)
        end
        
        add_package 'javascripts/application.js',  '{vendor,app,.}/javascripts/*.js'
        add_package 'stylesheets/application.css', '{vendor,app,.}/stylesheets/*.css'
        
        options.each do |to_file, from_files|
          add_package(to_file, from_files)
        end
      end
      
      def call(env)
        update_packages unless skip_update?(env)
        @app.call(env)
      end
      
      def add_package(output_file, source_files)
        public_output_file     = ::File.join(@options[:public_dir], output_file.to_s)
        @packages[output_file] = Rack::Pack::Package.new(public_output_file, source_files)
      end
      
      protected
      
      def update_packages
        @packages.each_value do |package|
          package.update if package.stale?
        end
        @updated = true
      end
      
      def skip_update?(env)
        return false if @options[:always_update]
        
        production = if defined?(RAILS_ENV)
          RAILS_ENV
        elsif defined?(Rails) && defined?(Rails.env)
          Rails.env
        else
          env['RACK_ENV']
        end.to_s == 'production'
        
        production && @updated
      end
    end
  end
end