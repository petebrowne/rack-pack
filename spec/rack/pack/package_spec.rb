require 'spec_helper'

describe Rack::Pack::Package do
  class MockPackage
    attr_accessor :output_file, :source_files
    def initialize(output_file, source_files)
      @output_file  = output_file
      @source_files = source_files
    end
  end
  
  def file_double(modified_at)
    double(:file, :mtime => modified_at, :exist? => true, :is_a? => true)
  end
  
  describe '.register' do
    it 'will store the package class for the given extension' do
      Rack::Pack::Package.register :mock, MockPackage
      Rack::Pack::Package.mappings['mock'].should == MockPackage
    end
  end
  
  describe '.mappings' do
    it 'should by default have a Javascript mapping' do
      Rack::Pack::Package.mappings['js'].should == Rack::Pack::Javascript
    end
    
    it 'should by default have a Stylesheet mapping' do
      Rack::Pack::Package.mappings['css'].should == Rack::Pack::Stylesheet
    end
  end
  
  describe '.[]' do
    it 'should find the correct package class for the given file' do
      Rack::Pack::Package['some/javascript.js'].should == Rack::Pack::Javascript
    end
    
    it 'should default to the base Package' do
      Rack::Pack::Package['missing.ext'].should == Rack::Pack::Package
    end
  end
  
  describe '#file' do
    context 'when initialized with a string' do
      it 'should convert it to a pathname' do
        package = Rack::Pack::Package.new('hello', [])
        package.file.should == Pathname.new('hello')
      end
    end
  
  describe '#source_files'
    context 'when initialized with an array of strings' do
      it 'should convert them to pathnames' do
        package = Rack::Pack::Package.new('', %w(file-1 file-2))
        package.source_files.should =~ [ Pathname.new('file-1'), Pathname.new('file-2') ]
      end
    end
  
    context 'when initialized with a string' do
      it 'should treat it as a Dir glob' do
        within_construct do |c|
          c.file 'dir/file-1.js'
          c.file 'dir/file-2.js'
          
          package = Rack::Pack::Package.new('', 'dir/*.js')
          package.source_files.should =~ [ Pathname.new('dir/file-1.js'), Pathname.new('dir/file-2.js') ]
        end
      end
    end
  end
  
  describe '#stale?' do
    context 'if the packed file is current' do
      subject do
        now = Time.now
        package = Rack::Pack::Package.new('', [
          file_double(now),
          file_double(1.week.ago),
          file_double(2.weeks.ago)
        ])
        package.stub(:file => file_double(now))
        package
      end
      
      it { should_not be_stale }
    end
    
    context 'if the packed file is old' do
      subject do
        package = Rack::Pack::Package.new('', [
          file_double(Time.now),
          file_double(1.week.ago),
          file_double(2.weeks.ago)
        ])
        package.stub(:file => file_double(1.week.ago))
        package
      end
      
      it { should be_stale }
    end
    
    context "if the packed file doesn't exist" do
      subject do
        Rack::Pack::Package.new(
          'missing/file',
          [
            file_double(Time.now),
            file_double(1.week.ago),
            file_double(2.weeks.ago)
          ]
        )
      end
      
      it { should be_stale }
    end
    
    context 'when given a glob string' do
      it 'should check for new files' do
        within_construct do |c|
          c.file 'directory/file-1'
          
          package = Rack::Pack::Package.new(
            file_double(2.weeks.ago),
            'directory/**/*'
          )
          package.stale?
          
          c.file 'directory/file-2'
          package.should be_stale
        end
      end
    end
  end
  
  describe '#update' do
    it 'should combine the files and write it to the output file' do
      within_construct do |c|
        to_file = c.file('packed-file', 'Stale Content')
        package = Rack::Pack::Package.new(
          to_file,
          [
            c.file('file-1', '1'),
            c.file('file-2', '2'),
            c.file('file-3', '3')
          ]
        )
        package.update
        to_file.read.should == '123'
      end
    end
  end
  
  describe '#compress?' do
    subject { Rack::Pack::Package.new('', '') }
    it { should_not be_compress }
    
    context 'in a production environment' do
      before { Rack::Pack.stub(:production? => true) }
      it { should be_compress }
    end
    
    context 'with the :always_compress option' do
      before { Rack::Pack.stub(:options => double(:options, :[] => true)) }
      it { should be_compress }
    end
  end
end
