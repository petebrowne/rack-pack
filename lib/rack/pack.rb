require 'rack'

module Rack
  class Pack
    autoload :Javascript, 'rack/pack/javascript'
    autoload :Package,    'rack/pack/package'
    autoload :Stylesheet, 'rack/pack/stylesheet'
    autoload :Version,    'rack/pack/version'
    
    DEFAULT_OPTIONS = {
      :public_dir     => 'public',
      :always_update  => false,
      :js_compression => {}
    }.freeze
    
    class << self
      attr_accessor :packages, :options, :environment
      
      def production?
        self.environment.to_s == 'production'
      end
    
      def add_package(output_file, source_files)
        public_output_file    = ::File.join(self.options[:public_dir], output_file.to_s)
        package_class         = Package[output_file]
        packages[output_file] = package_class.new(public_output_file, source_files)
      end
    end
    
    def initialize(app, options = {})
      @app = app
      
      Pack.packages    = {}
      Pack.options     = DEFAULT_OPTIONS.dup
      Pack.environment = if defined?(RAILS_ENV)
        RAILS_ENV # Rails 2
      elsif defined?(Rails) && defined?(Rails.env)
        Rails.env # Rails 3
      elsif defined?(app.settings) && defined?(app.settings.environment)
        app.settings.environment # Sinatra
      elsif ENV.key?('RACK_ENV')
        ENV['RACK_ENV']
      else
        :development
      end
      
      Pack.options.each_key do |key|
        Pack.options[key] = options.delete(key) if options.key?(key)
      end
      
      Pack.add_package 'javascripts/application.js',  '{vendor,app,.}/javascripts/*.js'
      Pack.add_package 'stylesheets/application.css', '{vendor,app,.}/stylesheets/*.css'
      
      options.each do |to_file, from_files|
        Pack.add_package(to_file, from_files)
      end
    end
    
    def call(env)
      update_packages unless skip_update?
      @app.call(env)
    end
    
    protected
    
    def update_packages
      Pack.packages.each_value do |package|
        package.update if package.stale?
      end
      @updated = true
    end
    
    def skip_update?
      return false if Pack.options[:always_update]
      Pack.production? && @updated
    end

    Package.register :js,  Javascript
    Package.register :css, Stylesheet
  end
end
