require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
describe WebResourceBundler::Filters::BundleFilter::Filter do
  before(:each) do
    clean_cache_dir
    @settings = settings
    @bundle_settings = bundle_settings
    @filter = Filters::BundleFilter::Filter.new(@bundle_settings, FileManager.new(@settings[:resource_dir], @settings[:cache_dir]))
    @block_data = @sample_block_helper.sample_block_data
    css_type = ResourceFileType::CSS
    js_type = ResourceFileType::JS
    items = [@block_data.files.select{|f| f.type[:ext] == 'css'}.map {|f| f.path}.sort] + [@bundle_settings[:protocol], @bundle_settings[:domain]]
    items += @bundle_settings[:md5_additional_data] if @bundle_settings[:md5_additional_data]
    @css_md5_value = Digest::MD5.hexdigest(items.flatten.join('|'))
    @css_bundle_file = File.join(@settings[:cache_dir], [css_type[:name] + '_' + @css_md5_value, 'en', css_type[:ext]].join('.'))
    items = [@block_data.scripts.map {|f| f.path}.sort] + [@bundle_settings[:protocol], @bundle_settings[:domain]]
    items += @bundle_settings[:md5_additional_data] if @bundle_settings[:md5_additional_data]
    js_md5_value = Digest::MD5.hexdigest(items.flatten.join('|'))
    @js_bundle_file = File.join(@settings[:cache_dir], [js_type[:name] + '_' + js_md5_value, 'en', js_type[:ext]].join('.'))
  end

  describe "#apply" do
    it "bundles each block_data resources in single file" do
      @filter.apply!(@block_data)
      @block_data.files.select{|f| f.type[:ext] == 'css'}.first.path.should == @css_bundle_file
      @block_data.scripts.first.path.should == @js_bundle_file
    end
  end

  describe "#get_md5" do
    it "returns md5 from sorted filepaths and another additional data" do
      @filter.get_md5(@block_data.files.select{|f| f.type[:ext] == 'css'}).should == @css_md5_value
    end
  end

  describe "#bundle_filepath" do
    it "returns filename of bundle constructed from passed files" do
      @filter.bundle_filepath(WebResourceBundler::ResourceFileType::CSS, @block_data.files.select{|f| f.type[:ext] == 'css'}).should == @css_bundle_file 
    end
  end

end

