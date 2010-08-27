module Rack
  module Pack
    class Middleware
      DEFAULT_OPTIONS = {
        :public_dir     => 'public',
        :always_update  => false,
        :js_compression => {}
      }.freeze
      
      class << self
        attr_accessor :options
      end
      
      def initialize(app, options = {})
        self.class.options = DEFAULT_OPTIONS.dup
        
        @app         = app
        @packages    = {}
        @environment = if defined?(RAILS_ENV)
          RAILS_ENV # Rails 2
        elsif defined?(Rails) && defined?(Rails.env)
          Rails.env # Rails 3
        elsif defined?(app.settings) && defined?(app.settings.environment)
          app.settings.environment # Sinatra
        else
          :development
        end
        
        self.class.options.each_key do |key|
          self.class.options[key] = options.delete(key) if options.key?(key)
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
        public_output_file     = ::File.join(self.class.options[:public_dir], output_file.to_s)
        package_class          = Rack::Pack::Package[output_file]
        @packages[output_file] = package_class.new(public_output_file, source_files)
      end
      
      protected
      
      def update_packages
        @packages.each_value do |package|
          package.update if package.stale?
        end
        @updated = true
      end
      
      def skip_update?(env)
        return false if self.class.options[:always_update]
        (env['RACK_ENV'] || @environment).to_s == 'production' && @updated
      end
    end
  end
end