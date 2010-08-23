require 'spec_helper'

describe Rack::Pack::Middleware do
  def build_app(*args)
    Rack::Builder.new do
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
        c.file 'javascripts/file-1.js', '1'
        c.file 'javascripts/file-2.js', '2'
        
        @app = build_app
        @app.call(request)
        File.read('public/javascripts/application.js').should == '12'
      end
    end
    
    it 'should pack stylesheets' do
      within_construct do |c|
        c.file 'stylesheets/file-1.css', '1'
        c.file 'stylesheets/file-2.css', '2'
        
        @app = build_app
        @app.call(request)
        File.read('public/stylesheets/application.css').should == '12'
      end
    end
    
    context 'on next request' do
      context 'with updates' do
        it 'should re-pack the files' do
          within_construct do |c|
            c.file 'stylesheets/file-1.css', '1'
            c.file 'stylesheets/file-2.css', '2'
            
            @app = build_app
            @app.call(request)
            File.read('public/stylesheets/application.css').should == '12'
            
            sleep 1
            c.file 'stylesheets/file-2.css', '3'
            @app.call(request)
            File.read('public/stylesheets/application.css').should == '13'
          end
        end
      end
    
      context 'without updates' do
        it 'should not re-pack the files' do
          within_construct do |c|
            c.file 'stylesheets/file-1.css', '1'
            c.file 'stylesheets/file-2.css', '2'
            
            @app = build_app
            @app.call(request)
            File.read('public/stylesheets/application.css').should == '12'
            
            sleep 1
            original_mtime = File.mtime('public/stylesheets/application.css')
            sleep 1
            @app.call(request)
            File.mtime('public/stylesheets/application.css').should == original_mtime
          end
        end
      end
    end
  end
end
