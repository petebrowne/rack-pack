require 'spec_helper'

describe Rack::Pack::Stylesheet do
  describe '#compile' do
    it 'should by default strip the concatenated output' do
      within_construct do |c|
        c.file 'input-1.css', '   1'
        c.file 'input-2.css', '2   '
        
        package = Rack::Pack::Stylesheet.new('output.css', 'input-*.css')
        package.compile.should == '12'
      end
    end
    
    describe 'with compression' do
      before do
        Rack::Pack.stub(:production? => true)
      end
      
      context 'when yui/compressor is required' do
        it 'should compress using YUI::JavaScriptCompressor' do
          reveal_const :YUI do
            within_construct do |c|
              c.file 'input.css', '1'
              
              compressor = double(:yui_compressor)
              compressor.should_receive(:compress).with('1').and_return('1')
              YUI::CssCompressor.should_receive(:new).with({}).and_return(compressor)
              Rack::Pack::Stylesheet.new('output.css', 'input.css').compile
            end
          end
        end
      end
      
      context 'when rainpress is required' do
        it 'should compress using Rainpress' do
          reveal_const :Rainpress do
            within_construct do |c|
              c.file 'input.css', '1'
              
              Rainpress.should_receive(:compress).with('1', {}).and_return('')
              Rack::Pack::Stylesheet.new('output.css', 'input.css').compile
            end
          end
        end
      end
    end
  end
end
