require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
describe WebResourceBundler::Filters::ImageEncodeFilter::Filter do

  before(:each) do
    @settings = settings
    @base64_settings = base64_settings
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
      it "encodes images in css and change filename" do
        block_data = @sample_block_helper.sample_block_data
        bundle_filename = @bundler_filter.bundle_filename(WebResourceBundler::ResourceFileType::CSS, block_data.styles)
        @bundler_filter.apply!(block_data)
        @filter.apply!(block_data)
        generated_files = block_data.styles.map {|f| f.name}
        generated_files.include?(@file_prefix + bundle_filename).should be_true
        generated_files.include?(@ie_file_prefix + bundle_filename).should be_true
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
        generated_files = @block_data.styles.map {|f| f.name}
        generated_files.size.should == 2*@files.size
        @files.each do |file|
          generated_files.include?(@ie_file_prefix + File.basename(file)).should be_true
          generated_files.include?(@file_prefix + File.basename(file)).should be_true
        end
      end

    end
    describe "#change_resulted_files!" do

      before(:each) do
        @block_data = @sample_block_helper.sample_block_data
        @block_data.child_blocks = []
        @block_data.files = []
        @block_data.files += [
          WebResourceBundler::ResourceFile.new_css_file('styles/1.css'),
          WebResourceBundler::ResourceFile.new_css_file('/4.css')
        ]
        @block_data.files << WebResourceBundler::ResourceFile.new_js_file('file/that/shouldnt/change.js')
        @block_data.condition = ""
      end

      it "modifies block data files" do
        @filter.change_resulted_files!(@block_data)
        ['base64_1.css', 'base64_4.css', 'base64_ie_1.css', 'base64_ie_4.css'].each do |path|
          @block_data.styles.map {|f| f.name }.include?(path).should be_true(path)
        end
        @block_data.scripts.first.name.should == 'file/that/shouldnt/change.js'
      end

    end
  end
end

