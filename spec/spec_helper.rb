#require 'simplecov'
#SimpleCov.start
require File.join(File.dirname(__FILE__), "../lib/web_resource_bundler")
require 'fileutils'
require File.join(File.dirname(__FILE__), 'sample_block_helper')
require 'logger'
include WebResourceBundler 

class WebResourceBundler::BlockData
  def inspect
    "BlockData " + @css.files.keys.inspect + @js.files.keys.inspect
  end
end
def clean_cache_dir
  FileUtils.rm_rf(File.join(File.dirname(__FILE__), '/public/cache'))
end

Spec::Runner.configure do |config|
  config.before(:all) do
    config.mock_with :rspec
    @styles = ["/sample.css","/foo.css", "/test.css", "/styles/boo.css"]
    @scripts = ["/set_cookies.js", "/seal.js", "/salog20.js", "/marketing.js"]
    @settings_hash = {
        :domain => "google.com",
        :language => "en",
        :encode_images => true,
        :max_image_size => 30,
        :resource_dir => File.join(File.dirname(__FILE__), '/public'),
        :bundle_files => true,
        :cache_dir => 'cache',
        :log_path => File.join(File.dirname(__FILE__), '/spec.log')
      }
    @settings = Settings.new @settings_hash
    @sample_block_helper = SampleBlockHelper.new(@styles, @scripts, @settings)
    @logger = Logger.new(STDOUT)
  end

  config.after(:all) do
    log_path = File.join(File.dirname(__FILE__), '/spec.log')
    File.delete(log_path) if File.exist?(log_path)
    clean_cache_dir
  end
end
