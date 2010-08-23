require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'
Rspec::Core::RakeTask.new

desc 'Open an irb session preloaded with this library'
task :console do
  sh 'irb -rubygems -I lib -r mock_ftp.rb'
end

task :default => :spec
