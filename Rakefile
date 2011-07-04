require 'rake'
require 'spec/rake/spectask'

require File.join(File.dirname(__FILE__), "version.rb")

task :build do
  system "gem build web_resource_bundler.gemspec"
end

task :install => :build do
  system "gem install web_resource_bundler-#{WebResourceBundler::VERSION}.gem"
end

task :release => :build do
  system "gem push web_resource_bundler-#{WebResourceBundler::VERSION}.gem"
end

desc "Run all specs"
Spec::Rake::SpecTask.new('spec' ) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb' ]
end
