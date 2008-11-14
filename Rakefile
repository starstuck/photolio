# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'


desc "Clean asset cache files (stylesheets and javascripts)"
task :clobber_asset_cache do
     stylesheet_path = "#{RAILS_ROOT}/public/stylesheets/"
     javascripts_path = "#{RAILS_ROOT}/public/javascripts/"
     [stylesheet_path, javascripts_path].each do |path|
       if File.directory? path
         Dir.foreach(path) do |file| 
	   if file =~ /\A_cache_/
             file_path = File.join(path, file)
             if File.file?(path + file)
	       File.delete(file_path)
	       puts "File '#{file_path}' removed"
	     end
	   end
         end
       end 
     end
end
