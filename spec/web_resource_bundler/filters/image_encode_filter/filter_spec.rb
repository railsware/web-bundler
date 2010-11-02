require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
describe WebResourceBundler::Filters::ImageEncodeFilter::Filter do

  before(:each) do
    @file_prefix = Filters::ImageEncodeFilter::CssGenerator::FILE_PREFIX
    @ie_file_prefix = Filters::ImageEncodeFilter::CssGenerator::IE_FILE_PREFIX
  end

  describe "#apply" do
    context "block was bundled" do
      it "encodes images in bundles by creating two files (for IE and others) if block_data without condition" do
        block_data = @sample_block_helper.sample_block_data
        Filters::BundleFilter::Filter.new(@settings, @logger).apply(block_data)
        Filters::ImageEncodeFilter::Filter.new(@settings, @logger).apply(block_data)
        block_data.css.files.include?(File.join(@settings.cache_dir, @file_prefix + block_data.css.bundle_filename(@settings))).should be_true
        block_data.css.files.include?(File.join(@settings.cache_dir, @ie_file_prefix + block_data.css.bundle_filename(@settings))).should be_true
      end

      it "encodes images in bundles by creating one file for IE if block_data is conditional block" do
        block_data = @sample_block_helper.sample_block_data.child_blocks.first
        Filters::BundleFilter::Filter.new(@settings, @logger).apply(block_data)
        Filters::ImageEncodeFilter::Filter.new(@settings, @logger).apply(block_data)
        block_data.css.files.include?(File.join(@settings.cache_dir, @ie_file_prefix + block_data.css.bundle_filename(@settings))).should be_true
      end
    end
    context "block wasn't bundled" do
      it "encodes separatly all css files" do
        block_data = @sample_block_helper.sample_block_data
        block_data.css = ResourceBundle::Data.new(ResourceBundle::CSS, ['/sample.css', '/foo.css'])
        Filters::ImageEncodeFilter::Filter.new(@settings, @logger).apply(block_data)
        #sample.css has proper images and should be encoded
        block_data.css.files.include?(File.join(@settings.cache_dir, @file_prefix + File.basename('sample.css'))).should be_true
        #foo.css has no images in there, so it shouldn't be encoded
        block_data.css.files.include?('/foo.css').should be_true
      end
    end
  end
end

