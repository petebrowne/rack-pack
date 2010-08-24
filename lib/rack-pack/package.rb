require 'pathname'

module Rack
  module Pack
    class Package
      attr_reader :to_file, :from_files, :options
      
      def initialize(to_file, from_files, options = {})
        @to_file    = to_pathname(to_file)
        @options    = {}
        @from_files = case from_files
        when Array
          from_files.map { |f| to_pathname(f) }
        when String
          Pathname.glob(from_files)
        end
      end
      
      def update
        @to_file.dirname.mkpath
        @to_file.open('w') do |file|
          file << compile
        end
      end
      
      def stale?
        from_files? && (to_file_missing? || from_files_newer?)
      end
      
      protected
      
      def compile
        @from_files.map(&:read).join
      end
      
      def to_pathname(file)
        file.is_a?(Pathname) ? file : Pathname.new(file)
      end
      
      def from_files?
        !@from_files.empty?
      end
      
      def to_file_missing?
        !@to_file.exist?
      end
      
      def from_files_newer?
        @from_files.map(&:mtime).max > @to_file.mtime
      end
    end
  end
end
