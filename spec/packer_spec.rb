require 'spec_helper'

describe Rack::Pack::Packer do
  def file_double(modified_at)
    double(:file, :mtime => modified_at, :exist? => true, :is_a? => true)
  end
  
  describe '.new' do
    context 'when given a string for the first argument' do
      it 'should convert it to a pathname' do
        packer = Rack::Pack::Packer.new('hello', [])
        packer.to_file.should be_a(Pathname)
      end
    end
    
    context 'when given an array of strings for the second argument' do
      it 'should convert them to pathnames' do
        packer = Rack::Pack::Packer.new('', %w(file-1 file-2))
        packer.from_files.should =~ [ Pathname.new('file-1'), Pathname.new('file-2') ]
      end
    end
    
    context 'when given a string for the second argument' do
      it 'should treat it as a Dir glob' do
        Pathname.should_receive(:glob).with('dir/*.js').and_return([])
        Rack::Pack::Packer.new('', 'dir/*.js')
      end
    end
  end
  
  describe '#stale?' do
    context 'if the packed file is current' do
      subject do
        now = Time.now
        Rack::Pack::Packer.new(
          file_double(now),
          [
            file_double(now),
            file_double(1.week.ago),
            file_double(2.weeks.ago)
          ]
        )
      end
      
      it { should_not be_stale }
    end
    
    context 'if the packed file is old' do
      subject do
        Rack::Pack::Packer.new(
          file_double(1.week.ago),
          [
            file_double(Time.now),
            file_double(1.week.ago),
            file_double(2.weeks.ago)
          ]
        )
      end
      
      it { should be_stale }
    end
    
    context "if the packed file doesn't exist" do
      subject do
        Rack::Pack::Packer.new(
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
  end
  
  describe '#update' do
    it 'should combine the files and write it to the output file' do
      within_construct do |c|
        to_file = c.file('packed-file', 'Stale Content')
        packer = Rack::Pack::Packer.new(
          to_file,
          [
            c.file('file-1', '1'),
            c.file('file-2', '2'),
            c.file('file-3', '3')
          ]
        )
        packer.update
        to_file.read.should == '123'
      end
    end
  end
end
