require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
describe WebResourceBundler::Filters::BundleFilter::Filter do
  before(:each) do
    clean_cache_dir
    @filter = Filters::BundleFilter::Filter.new(@settings, @logger, FileManager.new(@settings))
    @block_data = @sample_block_helper.sample_block_data
    css_type = ResourceBundle::CSS
    js_type = ResourceBundle::JS
    items = [@block_data.css.files.keys, @settings.domain, @settings.protocol]
    @css_md5_value = Digest::MD5.hexdigest(items.flatten.join('|'))
    @css_bundle_file = [css_type[:name] + '_' + @css_md5_value, @settings.language, css_type[:ext]].join('.')
    items = [@block_data.js.files.keys, @settings.domain, @settings.protocol]
    js_md5_value = Digest::MD5.hexdigest(items.flatten.join('|'))
    @js_bundle_file = [js_type[:name] + '_' + js_md5_value, @settings.language, js_type[:ext]].join('.')
  end

  it "creates cache folder on initialization" do
    File.exist?(File.join(@settings.resource_dir, @settings.cache_dir)).should be_true
  end

  describe "#apply" do
    it "bundles each block_data resources in single file" do
      @filter.apply(@block_data)
      @block_data.css.files.keys.should == [File.join(@settings.cache_dir, @css_bundle_file)]
      @block_data.js.files.keys.should == [File.join(@settings.cache_dir, @js_bundle_file)]
    end
  end

  describe "#get_md5" do
    it "returns md5 from filenames and else additional data" do
      @filter.get_md5(@block_data.css).should == @css_md5_value
    end
  end

  describe "#bundle_filename" do
    it "returns filename of bundle constructed from passed files" do
      @filter.bundle_filename(@block_data.css).should == @css_bundle_file 
    end
  end
end

