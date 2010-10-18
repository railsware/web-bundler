require File.join(File.dirname(__FILE__), "../lib/web_resource_bundler")
require 'fileutils'
require File.join(File.dirname(__FILE__), 'sample_block_helper')
include WebResourceBundler 

def clean_cache_dir
  FileUtils.rm_rf(File.join(File.dirname(__FILE__), '/public/cache'))
end
  
Spec::Runner.configure do |config|
  config.before(:all) do
    config.mock_with :rspec
    
    @styles = ["/sample.css","/foo.css", "/temp.css", "/styles/boo.css"]
    @scripts = ["/set_cookies.js", "/seal.js", "/salog20.js", "/marketing.js"]
    @sample_block_helper = SampleBlockHelper.new(@styles, @scripts)
  end
  config.before(:each) do
    @settings_hash = {
        :domen => "google.com",
        :language => "en",
        :encode_images => true,
        :max_image_size => 30,
        :resource_dir => File.join(File.dirname(__FILE__), '/public'),
        :bundle_files => true,
        :cache_dir => '/cache'
      }
    @settings = Settings.new @settings_hash
  end
end
