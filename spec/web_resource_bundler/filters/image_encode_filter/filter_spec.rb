require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
describe WebResourceBundler::Filters::ImageEncodeFilter::Filter do

  before(:each) do
    @settings        = settings
    @base64_settings = base64_settings
    @file_prefix     = Filters::ImageEncodeFilter::Filter::FILE_PREFIX
    @ie_file_prefix  = Filters::ImageEncodeFilter::Filter::IE_FILE_PREFIX
    @mhtml_prefix    = Filters::ImageEncodeFilter::Filter::MHTML_FILE_PREFIX 
    @file_manager    = FileManager.new(@settings[:resource_dir], @settings[:cache_dir])
    @filter          = Filters::ImageEncodeFilter::Filter.new(@base64_settings, @file_manager)
  end

  describe "#encoded_filepath" do
    it "should return new filename for css for all browsers except IE" do
      filename = "mycss.css"
      @filter.send(:css_filepath, filename).should == File.join(@settings[:cache_dir], @file_prefix + filename)
    end
  end

  describe "#mhtml_css_filepath" do
    it "should return new filename for css for IE" do
      filename = "2.css"
      @filter.send(:mhtml_css_filepath, filename).should == File.join(@settings[:cache_dir], @ie_file_prefix + filename)
    end
  end

  describe "#mhtml_filepath" do
    it "should return new filename for mhtml file for IE" do
      filename = "2.css"
      @filter.send(:mhtml_filepath, filename).should == File.join(@settings[:cache_dir], @mhtml_prefix + '2.mhtml')
    end
  end


  describe "#apply" do
    context "block was bundled" do

      before(:each) do
        @bundler_filter = Filters::BundleFilter::Filter.new(@base64_settings, @file_manager)
      end

      it "encodes images in css and change filename" do
        block_data = @sample_block_helper.sample_block_data
        bundle_filepath = @bundler_filter.send(:bundle_filepath, WebResourceBundler::ResourceFileType::CSS, block_data.styles)
        @bundler_filter.apply!(block_data)
        @filter.apply!(block_data)
        generated_files = block_data.files.map {|f| f.path}      
        generated_files.include?(File.join(@settings[:cache_dir], @file_prefix + File.basename(bundle_filepath))).should be_true
        generated_files.include?(File.join(@settings[:cache_dir], @ie_file_prefix + File.basename(bundle_filepath))).should be_true
      end

      it "changes type of styles files to CSS only" do
        block_data = @sample_block_helper.sample_block_data
        resource_file = WebResourceBundler::ResourceFile.new_css_file(styles.first)
        block_data.files = [resource_file]
        block_data.child_blocks = []
        @bundler_filter.apply!(block_data)
        @filter.apply!(block_data)
        block_data.files.size.should == 3
        %w{BASE64_CSS MHTML_CSS MHTML}.each do |type_name|
          type = eval("WebResourceBundler::ResourceFileType::" + type_name)
          block_data.files.select {|f| f.type == type}.size.should == 1
        end
      end
    end
    context "block wasn't bundled" do
      before(:each) do
        @block_data = @sample_block_helper.sample_block_data
        @block_data.child_blocks = []
        @block_data.files = []
        @files = %w{sample.css foo.css}
        @files.each do |f|
          @block_data.files << @sample_block_helper.construct_resource_file(f,'', WebResourceBundler::ResourceFileType::CSS)
        end
        @filter.apply!(@block_data)
      end

      it "encodes separately all css files" do
        generated_files = @block_data.styles.map {|f| f.path}
        generated_files.size.should == 2*@files.size
        @files.each do |file|
          generated_files.include?(File.join(@settings[:cache_dir], @ie_file_prefix + File.basename(file))).should be_true
          generated_files.include?(File.join(@settings[:cache_dir], @file_prefix + File.basename(file))).should be_true
        end
      end

    end
  end
end

