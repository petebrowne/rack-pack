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
  
  context 'with default settings' do
    it 'should pack javascripts' do
      within_construct do |c|
        c.file 'vendor/javascripts/file-1.js', '1'
        c.file 'javascripts/file-2.js',        '2'
        c.file 'javascripts/file-3.js',        '3'
        
        @app = build_app
        @app.call(request)
        File.read('public/javascripts/application.js').should == '123'
      end
    end
    
    it 'should pack stylesheets' do
      within_construct do |c|
        c.file 'vendor/stylesheets/file-1.css',  '1'
        c.file 'stylesheets/file-2.css', '2'
        c.file 'stylesheets/file-3.css', '3'
        
        @app = build_app
        @app.call(request)
        File.read('public/stylesheets/application.css').should == '123'
      end
    end
    
    it 'should not compress the packages' do
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
      context 'with updates' do
        it 'should re-pack the package' do
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
    
      context 'without updates' do
        it 'should not re-pack the package' do
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
  end
  
  context 'with some custom packages' do
    it 'should pack the files' do
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
    it 'should compress the packages' do
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
    it 'should not pack the files' do
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
    
    it 'should pack files only one time' do
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
    
    context 'with always_update option as true' do
      it 'should pack the files on each request' do
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
      it 'should pass the options to the javascript compressor' do
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
