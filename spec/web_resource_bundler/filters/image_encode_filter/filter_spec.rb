require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
describe WebResourceBundler::Filters::ImageEncodeFilter::Filter do

  before(:each) do
    @file_prefix = Filters::ImageEncodeFilter::CssGenerator::FILE_PREFIX
    @ie_file_prefix = Filters::ImageEncodeFilter::CssGenerator::IE_FILE_PREFIX
    @file_manager = FileManager.new @settings
    @filter = Filters::ImageEncodeFilter::Filter.new(@settings, @file_manager)
  end

  describe "#apply" do
    context "block was bundled" do
      before(:each) do
        @bundler_filter = Filters::BundleFilter::Filter.new(@settings, @file_manager)
      end
      it "encodes images in bundles by creating two files (for IE and others) if block_data without condition" do
        block_data = @sample_block_helper.sample_block_data
        bundle_filename = @bundler_filter.bundle_filename(block_data.css.type, block_data.css.files.keys)
        @bundler_filter.apply(block_data)
        @filter.apply(block_data)
        generated_files = block_data.css.files.keys
        generated_files.include?(File.join(@settings.cache_dir, @file_prefix + bundle_filename)).should be_true
        generated_files.include?(File.join(@settings.cache_dir, @ie_file_prefix + bundle_filename)).should be_true
      end

      it "encodes images in bundles by creating one file for IE if block_data is conditional block" do
        block_data = @sample_block_helper.sample_block_data.child_blocks.first
        bundle_filename = @bundler_filter.bundle_filename(block_data.css.type, block_data.css.files.keys)
        @bundler_filter.apply(block_data)
        @filter.apply(block_data)
        generated_files = block_data.css.files.keys
        generated_files.include?(File.join(@settings.cache_dir, @ie_file_prefix + bundle_filename)).should be_true
      end
    end
    context "block wasn't bundled" do
      it "encodes separatly all css files" do
        block_data = @sample_block_helper.sample_block_data
        block_data.css = @sample_block_helper.construct_resource_bundle(ResourceBundle::CSS, ['/sample.css', '/foo.css'])
        @filter.apply(block_data)
        generated_files = block_data.css.files.keys
        #sample.css has proper images and should be encoded
        generated_files.include?(File.join(@settings.cache_dir, @file_prefix + File.basename('sample.css'))).should be_true
        #foo.css has no images in there, so it shouldn't be encoded
        generated_files.include?('/foo.css').should be_true
      end
    end
    describe "#change_resulted_files" do
      before(:each) do
        @resources = {
          :css => ['styles/1.css', '/4.css'],
          :js => ['file/that/shouldnt/change.js'],
          :condition => ""
        }
      end
      it "returns resource hash with css files path modified" do
        result = @filter.change_resulted_files(@resources)
        ['base64_1.css', 'base64_4.css', 'base64_ie_1.css', 'base64_ie_4.css'].each do |path|
          result[:css].include?(path).should be_true(path)
        end
        result[:js].should == @resources[:js]
      end
      it "returns resource hash with css files only for IE of condition isn't empty" do
        @resources[:condition] = "if IE"
        result = @filter.change_resulted_files(@resources)
        ['base64_ie_1.css', 'base64_ie_4.css'].each do |path|
          result[:css].include?(path).should be_true(path)
        end
      end
    end
  end
end

