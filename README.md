# Rack::Pack

Rack::Pack is a piece of Rack Middleware that packages and optionally compresses assets such as javascripts and stylesheets into single files. In a development environment, assets will be packaged on each request if there have been changes to the source files. In a production environment, assets will only be packaged one time, and only if there have been changes.

### Why?

I've tried a dozen different asset packaging solutions including AssetPackager, BundleFu, Jammit,  Sprockets, etc...none of which were quite what I wanted. I didn't need any helpers, controllers, embedded images, rake tasks, or Yaml config files. I just wanted something to take my assets and package them into one file, and you're looking at it.

## Installation
    
    gem install rack-pack
    
## Basic Usage

    require 'rack-pack'
    use Rack::Pack
    
or in Rails:
    
    # Gemfile
    gem 'rack-pack'
    
    # config/application.rb
    config.middleware.use Rack::Pack
    
### Packages
    
Two files will be packaged out of the box: `javascripts/application.js` & `stylesheets/application.css`. Rack::Pack will look in `vendor/javascripts`, `app/javascripts`, & `./javascripts` for any .js files and `vendor/stylesheets`, `app/stylesheets`, & `./stylesheets` for any .css files. These files will be packaged in the order they're found.

To create your own packages, pass in the name of the output file and the source files as options:

    use Rack::Pack, 'js/main.js' => [
      'vendor/javascripts/jquery.js',
      'vendor/javascripts/swfobject.js,
      'app/javascripts/misc.js',
      'app/javascripts/main.js'
    ]
    # Creates a 'public/js/main.js' file
      
Notice how the output file is relative to the public dir. By default this is just `'public'`, but this can be changed using the `:public_dir` option:

    use Rack::Pack, :public_dir => 'html', 'js/main.js' => %w(js/plugins.js js/main.js)
    # Creates a 'html/js/main.js' file
  
You can also pass a glob string for the source files. This string will be used to search for new files on each request. The downside is the source files will be concatenated in the order they're found.

    use Rack::Pack, 'assets/scripts.js' => 'app/js/**/*.js'
    
In fact, this is how the default packages are declared:

    use Rack::Pack,
      'javascripts/application.js'  => '{vendor,app,.}/javascripts/*.js',
      'stylesheets/application.css' => '{vendor,app,.}/stylesheets/*.css'
      
Beautiful, isn't it? I don't think you can get simpler than that. No Yaml config files or rake tasks. You'll set it up once then forget about it completely. Well unless you have to add a new source file and you were explicity setting your source files for a package, but whatever.
      
### Compression
      
What good would an asset packager be without compression? Rack::Pack determines which javascript compressor you want to use based on which one has been required. 

    require 'packr'
    use Rack::Pack
    # would use Packr
    
or in Rails:

    # Gemfile
    gem 'jsmin'
    
    # config/application.rb
    config.middleware.use Rack::Pack
    # would use JSMin

To pass options to the javascript compressor just use the `:js_compressor` option:

    require 'packr'
    use Rack::Pack, :js_compression => { :shrink_vars => true }
    
By default, packages are only compressed in a production environment. If for some reason you want them to always be compressed, pass the `:always_compress` option:

    use Rack::Pack, :always_compress => true

## Heroku and other read-only filesystems

Because Rack::Pack relies on writing the packaged files, it won't package anything on Heroku. But, you could just check in your packaged files and push them to Heroku. I'll look into other options for future versions.

## Copyright

Copyright (c) 2010 [Peter Browne](http://petebrowne.com). See LICENSE for details.
