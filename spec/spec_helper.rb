require File.join(File.dirname(__FILE__), "../lib/web_resource_bundler")
require File.join(File.dirname(__FILE__), 'sample_block_helper')
include WebResourceBundler 

  
Spec::Runner.configure do |config|
  config.before(:all) do
    @settings_hash = {
        :domen => "google.com",
        :language => "en",
        :encode_images => true,
        :max_image_size => 30,
        :resource_dir => File.join(File.dirname(__FILE__), '/public'),
        :bundle_files => true
      }
    @styles = ["/sample.css","/foo.css", "/temp.css", "/boo.css"]
    @scripts = ["/set_cookies.js", "/seal.js", "/salog20.js", "/marketing.js"]
    @settings = Settings.new @settings_hash
    @sample_block_helper = SampleBlockHelper.new(@styles, @scripts)
  end
end
