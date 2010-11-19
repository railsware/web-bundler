require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
describe WebResourceBundler::Filters::ImageEncodeFilter::Filter do

  before(:each) do
    @file_prefix = Filters::ImageEncodeFilter::CssGenerator::FILE_PREFIX
    @ie_file_prefix = Filters::ImageEncodeFilter::CssGenerator::IE_FILE_PREFIX
    @file_manager = FileManager.new @settings
    @filter = Filters::ImageEncodeFilter::Filter.new(@base64_settings, @file_manager)
  end

  describe "#apply" do
    context "block was bundled" do
      before(:each) do
        @bundler_filter = Filters::BundleFilter::Filter.new(@base64_settings, @file_manager)
      end
      it "encodes images in two files (for IE and others) if block_data without condition" do
        block_data = @sample_block_helper.sample_block_data
        bundle_filename = @bundler_filter.bundle_filename(block_data.css)
        @bundler_filter.apply(block_data)
        @filter.apply(block_data)
        generated_files = block_data.css.files.keys
        generated_files.include?(@file_prefix + bundle_filename).should be_true
      end

      it "puts files for IE in separate child block_data with condition [if IE]" do
        block_data = @sample_block_helper.sample_block_data
        block_data.child_blocks = []
        bundle_filename = @bundler_filter.bundle_filename(block_data.css)
        @bundler_filter.apply(block_data)
        @filter.apply(block_data)
        block_data.child_blocks.size.should == 1
        block_data.child_blocks[0].condition == "[if IE]"
        generated_files = block_data.child_blocks[0].css.files.keys
        generated_files.include?(@ie_file_prefix + bundle_filename).should be_true
      end

      it "encodes images in bundles in one file for IE if block_data is conditional block" do
        block_data = @sample_block_helper.sample_block_data.child_blocks.first
        bundle_filename = @bundler_filter.bundle_filename(block_data.css)
        block_data.css.files.each_pair do |path, content|
          WebResourceBundler::CssUrlRewriter.rewrite_content_urls!(path, content) if File.extname(path) == '.css'
        end
        @bundler_filter.apply(block_data)
        @filter.apply(block_data)
        generated_files = block_data.css.files.keys
        generated_files.include?(@ie_file_prefix + bundle_filename).should be_true
      end
    end
    context "block wasn't bundled" do
      before(:each) do
        @block_data = @sample_block_helper.sample_block_data
        @block_data.child_blocks = []
        @block_data.css = @sample_block_helper.construct_resource_bundle(ResourceBundle::CSS, ['/sample.css', '/foo.css'])
        @filter.apply(@block_data)
      end

      it "encodes separately all css files" do
        @block_data.child_blocks.size.should == 1 
        @block_data.child_blocks[0].condition == "[if IE]"
        generated_files = @block_data.child_blocks.first.css.files.keys
        ['sample.css', 'foo.css'].each do |file|
          generated_files.include?(@ie_file_prefix + File.basename(file)).should be_true
        end
      end

      it "encodes separately all css files" do
        generated_files = @block_data.css.files.keys
        #sample.css has proper images and should be encoded
        ['sample.css', 'foo.css'].each do |file|
          generated_files.include?(@file_prefix + File.basename(file)).should be_true
        end
      end
    end
    describe "#change_resulted_files!" do
      before(:each) do
        @block_data = @sample_block_helper.sample_block_data
        @block_data.child_blocks = []
        @block_data.css.files = {'styles/1.css' => "", '/4.css' => ""}
        @block_data.js.files = {'file/that/shouldnt/change.js' => ""}
        @block_data.condition = ""
      end
      it "returns resource hash with css files path modified" do
        @filter.change_resulted_files!(@block_data)
        @block_data.child_blocks.size.should == 1
        @block_data.child_blocks.first.condition.should == "[if IE]"
        ['base64_1.css', 'base64_4.css'].each do |path|
          @block_data.css.files.keys.include?(path).should be_true(path)
        end
        ['base64_ie_1.css', 'base64_ie_4.css'].each do |path|
          @block_data.child_blocks.first.css.files.keys.include?(path).should be_true(path)
        end
        @block_data.js.files.keys.should == ['file/that/shouldnt/change.js']
      end
      it "returns resource hash with css files only for IE of condition isn't empty" do
        @block_data.condition = "if IE"
        @filter.change_resulted_files!(@block_data)
        ['base64_ie_1.css', 'base64_ie_4.css'].each do |path|
          @block_data.css.files.keys.include?(path).should be_true(path)
        end
        @block_data.child_blocks.should be_empty
      end
    end
  end
end

