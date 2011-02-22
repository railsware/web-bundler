#require 'simplecov'
#SimpleCov.start
require File.join(File.dirname(__FILE__), "../lib/web_resource_bundler")
require 'fileutils'
require File.join(File.dirname(__FILE__), 'sample_block_helper')
require 'logger'
include WebResourceBundler 

def p(args)
  raise 'hah'
end

def clean_cache_dir
  cache_dir_path = File.join(File.dirname(__FILE__), '/public/cache')
  FileUtils.rm_rf(cache_dir_path) if File.exist?(cache_dir_path)
end

def styles
  ["/sample.css","/foo.css", "/test.css", "/styles/boo.css"]
end

def scripts
  ["/set_cookies.js", "/seal.js", "/salog20.js", "/marketing.js"]
end

def root_dir
  File.join(File.dirname(__FILE__), 'test_data')
end

def settings
  {
    :resource_dir => File.join(root_dir, '/public'),
    :cache_dir => 'cache',
    :log_path => File.join(root_dir, '/log/bundler.log'),
    :protocol => 'http',
    :domain => 'localhost:3000',
    :base64_filter => {
      :use => true,
      :max_image_size => 23, #kbytes
    },
    :bundle_filter => {
      :use => true,
      :filename_additional_data => ['en']
    },
    :cdn_filter => {
      :use => true,
      :http_hosts => ['http://localhost:3000'],
      :https_hosts => ['https://localhost:3000']
    }
  }
end

def bundle_settings
  settings[:bundle_filter].merge(common_settings)
end

def cdn_settings
  settings[:cdn_filter].merge(common_settings)
end

def base64_settings
  settings[:base64_filter].merge(common_settings)
end

def common_settings
  {
    :resource_dir => settings[:resource_dir], 
    :cache_dir => settings[:cache_dir],
    :domain => settings[:domain],
    :protocol => settings[:protocol]
  }
end


Spec::Runner.configure do |config|
  config.before(:all) do
    config.mock_with :rspec
  end
  config.before(:all) do
    @sample_block_helper = SampleBlockHelper.new(styles, scripts, settings)
    @logger = Logger.new(STDOUT)
  end

  config.after(:all) do
    File.delete(settings[:log_path]) if File.exist?(settings[:log_path])
    log_path = File.expand_path('../log', settings[:resource_dir])
    FileUtils.rm_rf(log_path) if File.exist?(log_path)
    clean_cache_dir
  end
end
