require 'pathname'

module Rack
  class Pack
    class Package
      class << self
        def mappings
          @package_mappings ||= {}
        end
        
        def register(ext, package_class)
          ext = ext.to_s.sub(/^\./, '').downcase
          mappings[ext] = package_class
        end
        
        def [](file)
          ext = ::File.extname(file.to_s).sub(/^\./, '').downcase
          mappings[ext] || self
        end
      end
      
      attr_reader :file
      
      def initialize(output_file, source_files)
        @file = to_pathname(output_file)
        @from = if source_files.is_a?(Array)
          source_files.map { |file| to_pathname(file) }
        else
          source_files.to_s
        end
      end
      
      def update
        file.dirname.mkpath
        file.open('w') do |file|
          file << compile
        end
      end
      
      def compile
        @size = source_files.size
        compiled = source_files.map(&:read).join
        compiled = compress(compiled) if compress?
        compiled.strip
      end
      
      def compress(source)
        source
      end
      
      def stale?
        @source_files = nil
        source_files? && (file_missing? || source_files_added_or_removed? || source_files_newer?)
      end
      
      def source_files
        @source_files ||= glob? ? Pathname.glob(@from) : @from
      end
      
      def compress?
        Pack.production? || Pack.options && Pack.options[:always_compress]
      end
      
      protected
      
        def to_pathname(file)
          file.is_a?(Pathname) ? file : Pathname.new(file)
        end
        
        def glob?
          @from.is_a?(String)
        end
        
        def source_files?
          !source_files.empty?
        end
        
        def file_missing?
          !file.exist?
        end
        
        def source_files_added_or_removed?
          glob? && source_files.size != @size
        end
        
        def source_files_newer?
          source_files.map(&:mtime).max > file.mtime
        end
    end
  end
end
