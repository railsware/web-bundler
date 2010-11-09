require 'rake'
require 'spec/rake/spectask'
require 'rubygems'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "web_resource_bundler"
    gem.summary = %Q{lib for css and js content bundling and managment}
    gem.description = %Q{this lib could bundle you css/js files in single file, encode images in base64, rewrite images urls to your cdn hosts}
    gem.email = "anotheroneman@yahoo.com"
    gem.homepage = "http://github.com/gregolsen/web_resource_bundler"
    gem.authors = ["gregolsen"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :spec do

  desc "Run specs with RCov"
    Spec::Rake::SpecTask.new('rcov' ) do |t|
      t.spec_files = FileList['spec/**/*_spec.rb' ]
      t.rcov = true
    end

  desc "Run specs on different ruby platforms using rvm"
    Spec::Rake::SpecTask.new('all') do |t|
      #ruby_versions = ['system', '1.8.7', '1.8.6']
      #ruby_versions.each do |v|
      #  t.spec_files = FileList['spec/**/*_spec.rb' ]
      #  system("rvm #{v}")
      #  puts system('ruby -v')
      #  Rake::Task['spec'].invoke
      #end
    end

end
