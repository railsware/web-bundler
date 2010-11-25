require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
describe WebResourceBundler::Filters::BundleFilter::Filter do
  before(:each) do
    clean_cache_dir
    @settings = settings
    @bundle_settings = bundle_settings
    @filter = Filters::BundleFilter::Filter.new(@bundle_settings, FileManager.new(@settings))
    @block_data = @sample_block_helper.sample_block_data
    css_type = ResourceFileType::CSS
    js_type = ResourceFileType::JS
    items = [@block_data.styles.map {|f| f.name}.sort] + @bundle_settings[:md5_additional_data]
    @css_md5_value = Digest::MD5.hexdigest(items.flatten.join('|'))
    @css_bundle_file = [css_type[:name] + '_' + @css_md5_value, 'en', css_type[:ext]].join('.')
    items = [@block_data.scripts.map {|f| f.name}.sort]  + @bundle_settings[:md5_additional_data]
    js_md5_value = Digest::MD5.hexdigest(items.flatten.join('|'))
    @js_bundle_file = [js_type[:name] + '_' + js_md5_value, 'en', js_type[:ext]].join('.')
  end

  describe "#apply" do
    it "bundles each block_data resources in single file" do
      @filter.apply!(@block_data)
      @block_data.styles.first.name.should == @css_bundle_file
      @block_data.scripts.first.name.should == @js_bundle_file
    end
  end

  describe "#get_md5" do
    it "returns md5 from sorted filenames and another additional data" do
      @filter.get_md5(@block_data.styles).should == @css_md5_value
    end
  end

  describe "#bundle_filename" do
    it "returns filename of bundle constructed from passed files" do
      @filter.bundle_filename(WebResourceBundler::ResourceFileType::CSS, @block_data.styles).should == @css_bundle_file 
    end
  end

  describe "#change_resulted_files!" do
    it "changes files paths in array to one bundle file name" do
      sample = @sample_block_helper.sample_block_data
      sample.child_blocks = []
      @filter.change_resulted_files!(sample)
      sample.styles.first.name.should == @filter.bundle_filename(WebResourceBundler::ResourceFileType::CSS, @block_data.styles)
      sample.scripts.first.name.should == @filter.bundle_filename(WebResourceBundler::ResourceFileType::JS, @block_data.scripts)
    end

  end
end

