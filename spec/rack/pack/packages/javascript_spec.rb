require 'spec_helper'

describe Rack::Pack::Packages::Javascript do
  describe '#compile' do
    it 'should by default strip the concatenated output' do
      within_construct do |c|
        c.file 'input-1.js', '   1'
        c.file 'input-2.js', '2   '
        
        package = Rack::Pack::Packages::Javascript.new('output.js', 'input-*.js')
        package.compile.should == '12'
      end
    end
    
    context 'when JSMin is required' do
      it 'should compress using JSMin' do
        require 'jsmin'
        within_construct do |c|
          c.file 'input.js', 'function(number) { return number + 2; }'
          
          package = Rack::Pack::Packages::Javascript.new('output.js', 'input.js')
          package.compile.should == 'function(number){return number+2;}'
        end
        Object.send :remove_const, :JSMin
      end
    end
    
    context 'when packr is required' do
      it 'should compress using Packr' do
        require 'packr'
        within_construct do |c|
          c.file 'input.js', '1'
          
          Packr.should_receive(:pack).with('1', :shrink_vars => true).and_return('1')
          Rack::Pack::Packages::Javascript.new('output.js', 'input.js').compile
        end
        Object.send :remove_const, :Packr
      end
    end
  end
end
