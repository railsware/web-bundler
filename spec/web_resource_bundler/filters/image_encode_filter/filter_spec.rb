require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
describe WebResourceBundler::Filters::ImageEncodeFilter::Filter do

  before(:each) do
    @settings = settings
    @base64_settings = base64_settings
    @file_prefix = Filters::ImageEncodeFilter::Filter::FILE_PREFIX
    @ie_file_prefix = Filters::ImageEncodeFilter::Filter::IE_FILE_PREFIX
    @file_manager = FileManager.new(@settings.resource_dir, @settings.cache_dir)
    @filter = Filters::ImageEncodeFilter::Filter.new(@base64_settings, @file_manager)
  end

  describe "#encoded_filepath" do
    it "should return new filename for css for all browsers except IE" do
      filename = "mycss.css"
      @filter.encoded_filepath(filename).should == File.join(@settings.cache_dir, @file_prefix + filename)
    end
  end

  describe "#new_filepath_for_ie" do
    it "should return new filename for css for IE" do
      filename = "2.css"
      @filter.encoded_filepath_for_ie(filename).should == File.join(@settings.cache_dir, @ie_file_prefix + filename)
    end
  end

  describe "#mhtml_filepath" do
    it "returns mhtml file path" do
      @filter.mhtml_filepath('styles/1.css').should == 'cache/1.mhtml'
    end
  end

  describe "#apply" do
    context "block was bundled" do
      before(:each) do
        @bundler_filter = Filters::BundleFilter::Filter.new(@base64_settings, @file_manager)
      end
      it "encodes images in css and change filename" do
        block_data = @sample_block_helper.sample_block_data
        bundle_filepath = @bundler_filter.bundle_filepath(WebResourceBundler::ResourceFileType::CSS, block_data.styles)
        @bundler_filter.apply!(block_data)
        @filter.apply!(block_data)
        generated_files = block_data.files.map {|f| f.path}
        generated_files.include?(File.join(@settings.cache_dir, @file_prefix + File.basename(bundle_filepath))).should be_true
        generated_files.include?(File.join(@settings.cache_dir, @ie_file_prefix + File.basename(bundle_filepath))).should be_true
      end

    end
    context "block wasn't bundled" do
      before(:each) do
        @block_data = @sample_block_helper.sample_block_data
        @block_data.child_blocks = []
        @block_data.files = []
        @files = %w{sample.css foo.css}
        @files.each do |f|
          @block_data.files << @sample_block_helper.construct_resource_file(WebResourceBundler::ResourceFileType::CSS, f)
        end
        @filter.apply!(@block_data)
      end

      it "encodes separately all css files" do
        generated_files = @block_data.styles.map {|f| f.path}
        generated_files.size.should == 2*@files.size
        @files.each do |file|
          generated_files.include?(File.join(@settings.cache_dir, @ie_file_prefix + File.basename(file))).should be_true
          generated_files.include?(File.join(@settings.cache_dir, @file_prefix + File.basename(file))).should be_true
        end
      end

    end
  end
end

