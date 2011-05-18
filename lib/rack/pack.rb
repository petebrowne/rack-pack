require 'rack'

module Rack
  class Pack
    autoload :Javascript, 'rack/pack/javascript'
    autoload :Package,    'rack/pack/package'
    autoload :Stylesheet, 'rack/pack/stylesheet'
    autoload :Version,    'rack/pack/version'
    
    class << self
      attr_accessor :packages, :environment, :options
    end
    
    # Setup the defaults
    @packages    = {}
    @environment = 'development'
    @options     = {
      :public_dir           => 'public',
      :add_default_packages => true,
      :always_update        => false,
      :always_compress      => false,
      :js_compression       => {},
      :css_compression      => {}
    }
    
    class << self
      # Sets up Rack::Pack, optionally adding packages.
      #
      # @param [Hash] options
      # @option options [String] :public_dir ('public') The directory to output the packaged file.
      # @option options [Boolean] :add_default_packages (true) Wether or not to add the default packages.
      # @option options [Boolean] :always_update (false) Updates the packages on every request.
      # @option options [Boolean] :always_compress (false) Compress the packages on every request.
      # @option options [Hash] :js_compression Options to pass directly
      #   to the Javascript compression engine.
      # @option options [Hash] :css_compression Options to pass directly
      #   to the Stylesheet compression engine.
      # @option options [String] :environment Manually set the environment.
      def configure(options = {})
        self.options.each_key do |key|
          self.options[key] = options.delete(key) if options.key?(key)
        end
        
        self.environment = options.delete(:environment) if options.key?(:environment)
        
        add_default_packages if self.options[:add_default_packages]
      
        options.each do |to_file, from_files|
          add_package(to_file, from_files)
        end
      end
      
      # Determines if we're running in a production environment.
      def production?
        self.environment.to_s == 'production'
      end
    
      # Adds a new Package for Rack::Pack to update.
      # The Package class is determined based on the filename.
      #
      # @param [String] output_file The path to the file the Package will output.
      # @param [Array, String] source_files The source files to package. Can be either
      #   an Array of individual source files or a string that will be used in a glob.
      def add_package(output_file, source_files)
        if source_files.nil?
          packages.delete(output_file)
        else
          public_output_file    = ::File.join(options[:public_dir], output_file.to_s)
          package_class         = Package[output_file]
          packages[output_file] = package_class.new(public_output_file, source_files)
        end
      end
      
      # Adds the default Packages, which essentially look in the `vendor`, `app`,
      # and current directories for javascripts & stylesheets and packages them into
      # `javascripts/application.js` & `stylesheets/application.css`
      def add_default_packages
        add_package 'javascripts/application.js',  '{vendor,app,.}/javascripts/*.js'
        add_package 'stylesheets/application.css', '{vendor,app,.}/stylesheets/*.css'
      end
      
      # Loops through each added Package and updates them when stale.
      def update_packages
        Pack.packages.each_value do |package|
          package.update if package.stale?
        end
      end
    end
    
    # Interface for creating the Rack::Pack middleware.
    #
    # @param []
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
        Pack.update_packages
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
