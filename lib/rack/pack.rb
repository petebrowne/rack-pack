require 'rack'

module Rack
  class Pack
    autoload :Javascript, 'rack/pack/javascript'
    autoload :Package,    'rack/pack/package'
    autoload :Stylesheet, 'rack/pack/stylesheet'
    autoload :Version,    'rack/pack/version'
    
    DEFAULT_OPTIONS = {
      :public_dir           => 'public',
      :always_update        => false,
      :always_compress      => false,
      :js_compression       => {},
      :css_compression      => {},
      :environment          => :development,
      :add_default_packages => true
    }.freeze
    
    class << self
      attr_accessor :packages, :options, :environment
      
      def configure(options = {})
        self.packages = {}
        self.options  = DEFAULT_OPTIONS.dup
      
        self.options.each_key do |key|
          self.options[key] = options.delete(key) if options.key?(key)
        end
        
        unless self.options[:add_default_packages] == false
          add_package 'javascripts/application.js',  '{vendor,app,.}/javascripts/*.js'
          add_package 'stylesheets/application.css', '{vendor,app,.}/stylesheets/*.css'
        end
      
        options.each do |to_file, from_files|
          add_package(to_file, from_files)
        end
      end
      
      def production?
        self.environment.to_s == 'production'
      end
    
      def add_package(output_file, source_files)
        if source_files.nil?
          packages.delete(output_file)
        else
          public_output_file    = ::File.join(self.options[:public_dir], output_file.to_s)
          package_class         = Package[output_file]
          packages[output_file] = package_class.new(public_output_file, source_files)
        end
      end
    end
    
    def initialize(app, options = {})
      @app = app
      Pack.configure(options)
      
      # Set environment based on Application environment
      if defined?(RAILS_ENV)
        Pack.environment = RAILS_ENV # Rails 2
      elsif defined?(Rails) && defined?(Rails.env)
        Pack.environment = Rails.env # Rails 3
      elsif defined?(app.settings) && defined?(app.settings.environment)
        Pack.environment = app.settings.environment # Sinatra
      elsif ENV.key?('RACK_ENV')
        Pack.environment = ENV['RACK_ENV']
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
