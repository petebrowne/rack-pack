require 'spec_helper'

describe Rack::Pack do
  def build_app(*args)
    Rack::Builder.app do
      use Rack::Lint
      use Rack::Pack, *args
      run lambda { |env| [ 200, { 'Content-Type' => 'text/html' }, [ 'Hello World!' ] ] }
    end
  end
  
  def request_for(url = '/')
    Rack::MockRequest.env_for(url)
  end
  alias_method :request, :request_for
  
  describe '.configure' do
    it 'sets the given options' do
      Rack::Pack.configure(:public_dir => '_site', :always_compress => true, :environment => :production)
      Rack::Pack.options.should == {
        :public_dir           => '_site',
        :always_update        => false,
        :always_compress      => true,
        :js_compression       => {},
        :css_compression      => {},
        :environment          => :production,
        :add_default_packages => true
      }
    end
    
    it 'adds default packages' do
      Rack::Pack.configure
      Rack::Pack.packages['javascripts/application.js'].should be_an_instance_of(Rack::Pack::Javascript)
      Rack::Pack.packages['stylesheets/application.css'].should be_an_instance_of(Rack::Pack::Stylesheet)
    end
    
    it 'adds given packages' do
      Rack::Pack.configure('main.js' => %w(vendor/javascripts/file-1.js app/javascripts/file-2.js))
      Rack::Pack.packages['main.js'].should be_an_instance_of(Rack::Pack::Javascript)
    end
    
    context 'with :add_default_packages => false' do
      it 'does not add default packages' do
        Rack::Pack.configure(:add_default_packages => false)
        Rack::Pack.packages['javascripts/application.js'].should be_nil
        Rack::Pack.packages['stylesheets/application.css'].should be_nil
      end
    end
  end
  
  context '.update_packages' do
    it 'packs javascripts' do
      within_construct do |c|
        c.file 'vendor/javascripts/file-1.js', '1'
        c.file 'javascripts/file-2.js',        '2'
        c.file 'javascripts/file-3.js',        '3'
        
        Rack::Pack.configure
        Rack::Pack.update_packages
        File.read('public/javascripts/application.js').should == '123'
      end
    end
    
    it 'packs stylesheets' do
      within_construct do |c|
        c.file 'vendor/stylesheets/file-1.css',  '1'
        c.file 'stylesheets/file-2.css', '2'
        c.file 'stylesheets/file-3.css', '3'
        
        Rack::Pack.configure
        Rack::Pack.update_packages
        File.read('public/stylesheets/application.css').should == '123'
      end
    end
  end
  
  context 'with default settings' do
    it 'packs javascripts' do
      within_construct do |c|
        c.file 'vendor/javascripts/file-1.js', '1'
        c.file 'javascripts/file-2.js',        '2'
        c.file 'javascripts/file-3.js',        '3'
        
        @app = build_app
        @app.call(request)
        File.read('public/javascripts/application.js').should == '123'
      end
    end
    
    it 'packs stylesheets' do
      within_construct do |c|
        c.file 'vendor/stylesheets/file-1.css',  '1'
        c.file 'stylesheets/file-2.css', '2'
        c.file 'stylesheets/file-3.css', '3'
        
        @app = build_app
        @app.call(request)
        File.read('public/stylesheets/application.css').should == '123'
      end
    end
    
    it 'does not compress the packages' do
      reveal_const :JSMin do
        within_construct do |c|
          c.file 'app/javascripts/file.js', '1'
          
          JSMin.should_not_receive(:minify)
          @app = build_app
          @app.call(request)
        end
      end
    end
    
    context 'on next request' do
      context 'when files are updated' do
        it 're-packs the package' do
          within_construct do |c|
            c.file 'app/stylesheets/file-1.css', '1'
            c.file 'app/stylesheets/file-2.css', '2'
            
            @app = build_app
            @app.call(request)
            File.read('public/stylesheets/application.css').should == '12'
            
            sleep 1
            c.file 'app/stylesheets/file-2.css', '3'
            @app.call(request)
            File.read('public/stylesheets/application.css').should == '13'
          end
        end
      end
    
      context 'when files are not updated' do
        it 'does not re-pack the package' do
          within_construct do |c|
            c.file 'app/stylesheets/file-1.css', '1'
            c.file 'app/stylesheets/file-2.css', '2'
            
            @app = build_app
            @app.call(request)
            File.read('public/stylesheets/application.css').should == '12'
            original_mtime = File.mtime('public/stylesheets/application.css')
            
            sleep 1
            @app.call(request)
            File.mtime('public/stylesheets/application.css').should == original_mtime
          end
        end
      end
    end
    
    context 'when files are added' do
      it 're-packs the package' do
        within_construct do |c|
          c.file 'app/stylesheets/file-1.css', '1'
          c.file 'app/stylesheets/file-2.css', '2'
          
          @app = build_app
          @app.call(request)
          File.read('public/stylesheets/application.css').should == '12'
          
          sleep 1
          c.file 'app/stylesheets/file-3.css', '3'
          @app.call(request)
          File.read('public/stylesheets/application.css').should == '123'
        end
      end
    end
    
    context 'when files are removed' do
      it 're-packs the package' do
        within_construct do |c|
          c.file 'app/stylesheets/file-1.css', '1'
          c.file 'app/stylesheets/file-2.css', '2'
          
          @app = build_app
          @app.call(request)
          File.read('public/stylesheets/application.css').should == '12'
          
          sleep 1
          FileUtils.rm 'app/stylesheets/file-2.css'
          @app.call(request)
          File.read('public/stylesheets/application.css').should == '1'
        end
      end
    end
  end
  
  context 'with some custom packages' do
    it 'packs the files' do
      within_construct do |c|
        c.file 'vendor/javascripts/file-1.js', '1'
        c.file 'app/javascripts/file-2.js',    '2'
        
        @app = build_app 'main.js' => %w(vendor/javascripts/file-1.js app/javascripts/file-2.js)
        @app.call(request)
        File.read('public/main.js').should == '12'
      end
    end
  end
  
  context 'with :always_compress on' do
    it 'compresses the packages' do
      reveal_const :JSMin do
        within_construct do |c|
          c.file 'app/javascripts/file.js', '1'
          
          JSMin.should_receive(:minify).with('1').and_return('1')
          @app = build_app :always_compress => true
          @app.call(request)
        end
      end
    end
  end
  
  context 'with a default package set to nil' do
    it 'does not pack the files' do
      within_construct do |c|
        c.file 'vendor/javascripts/file-1.js', '1'
        
        @app = build_app 'javascripts/application.js' => nil
        @app.call(request)
        File.exist?('public/javascripts/application.js').should_not be_true
      end
    end
  end
  
  context 'in a production environment' do
    before do
      Rails = double('rails', :env => double('env', :to_s => 'production'))
    end
    
    after do
      Object.send(:remove_const, :Rails)
    end
    
    it 'packs files only one time' do
      within_construct do |c|
        c.file 'app/javascripts/file.js', '1'
        
        @app = build_app
        @app.call(request)
        
        sleep 1
        c.file 'app/javascripts/file.js', '2'
        @app.call(request)
        File.read('public/javascripts/application.js').should == '1'
      end
    end
    
    context 'with :always_update => true' do
      it 'packs the files on each request' do
        within_construct do |c|
          c.file 'app/javascripts/file.js', '1'
          
          @app = build_app :always_update => true
          @app.call(request)
          
          sleep 1
          c.file 'app/javascripts/file.js', '2'
          @app.call(request)
          File.read('public/javascripts/application.js').should == '2'
        end
      end
    end
  
    context 'with javascript compression options' do
      it 'passes the options to the javascript compressor' do
        reveal_const :Packr do
          within_construct do |c|
            c.file 'app/javascripts/file.js', '1'
            
            Packr.should_receive(:pack).with('1', :shrink_vars => false).and_return('1')
            @app = build_app :js_compression => { :shrink_vars => false }
            @app.call(request)
          end
        end
      end
    end
  end
end
