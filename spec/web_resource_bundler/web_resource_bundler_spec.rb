require File.expand_path(File.join(File.dirname(__FILE__), "../spec_helper"))
module WebResourceBundler
  describe Bundler do

    before(:each) do
      @bundler = WebResourceBundler::Bundler.new(@settings_hash)
    end

    describe "#bundle_upto_date?" do
      it "returns true if block was already bundled and resulted files exist" do
        clean_cache_dir
        block_text = @sample_block_helper.sample_block
        block_data = BlockParser.new.parse(block_text.dup)
        @bundler.bundle_upto_date?(block_data).should == false
        @bundler.process(block_text)
        @bundler.bundle_upto_date?(block_data).should == true
      end
    end


    describe "#read_resources!" do
      it "populates block_data resource files structure with files content" do
        block_data = @sample_block_helper.sample_block_data
        @bundler.read_resources!(block_data)
        all_files = block_data.css.files.merge(block_data.js.files).merge(block_data.child_blocks[0].css.files).merge(block_data.child_blocks[0].js.files)
        all_files.each_pair do |path, content|
          CssUrlRewriter::rewrite_content_urls!(path, File.read(File.join(@settings.resource_dir, path))).should == content
        end
      end
    end

  end
end
