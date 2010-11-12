#require 'simplecov'
#SimpleCov.start
require File.join(File.dirname(__FILE__), "../lib/web_resource_bundler")
require 'fileutils'
require File.join(File.dirname(__FILE__), 'sample_block_helper')
require 'logger'
include WebResourceBundler 

def clean_cache_dir
  FileUtils.rm_rf(File.join(File.dirname(__FILE__), '/public/cache'))
end

Spec::Runner.configure do |config|
  config.before(:all) do
    config.mock_with :rspec
    @styles = ["/sample.css","/foo.css", "/test.css", "/styles/boo.css"]
    @scripts = ["/set_cookies.js", "/seal.js", "/salog20.js", "/marketing.js"]
    @settings_hash = {
        :resource_dir => File.join(File.dirname(__FILE__), '/public'),
        :cache_dir => 'cache',
        :log_path => File.join(File.dirname(__FILE__), '/spec.log'),
        :base64_filter => {
          :max_image_size => 23, #kbytes
          :protocol => 'http',
          :domain => 'localhost:3000'
        },
        :bundle_filter => {
          :md5_additional_data => ['localhost:3000', 'http'],
          :filename_additional_data => ['en']
        },
        :cdn_filter => {
          :http_hosts => ['http://localhost:3000'],
          :https_hosts => ['https://localhost:3000']
        }
      }
    @settings = Settings.new @settings_hash
    common = {:resource_dir => @settings.resource_dir, :cache_dir => @settings.cache_dir}
    @bundle_settings = @settings.bundle_filter.merge(common) 
    @base64_settings = @settings.base64_filter.merge(common)
    @cdn_settings = @settings.cdn_filter.merge(common)
    @sample_block_helper = SampleBlockHelper.new(@styles, @scripts, @settings)
    @logger = Logger.new(STDOUT)
  end

  config.after(:all) do
    log_path = File.join(File.dirname(__FILE__), '/spec.log')
    File.delete(log_path) if File.exist?(log_path)
    clean_cache_dir
  end
end
