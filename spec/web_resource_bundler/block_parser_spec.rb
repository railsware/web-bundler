require File.absolute_path(File.join(File.dirname(__FILE__), "../spec_helper"))
module WebResourceBundler
  describe BlockParser do

    describe "#remove_links" do
      it "deletes all links to resources (js, css) from block" do
        block = @sample_block_helper.construct_links_block(@styles, @scripts)
        block += @sample_block_helper.sample_inline_block
        block += @sample_block_helper.construct_links_block(@styles, @scripts)
        block += @sample_block_helper.sample_inline_block
        BlockParser.remove_links(block).should == @sample_block_helper.sample_inline_block + @sample_block_helper.sample_inline_block
      end
    end

    describe "#parse" do

      it "returns BlockData object" do
        BlockParser.parse("").is_a?(BlockData).should be_true
      end

      it "returns empty BlockData when block is empty" do
        data = BlockParser.parse("")
        data.css.files.should be_empty
        data.js.files.should be_empty
      end
      
      def compare_block_datas(a,b)
        (a.css.files - b.css.files).should be_empty
        (a.js.files - b.js.files).should be_empty
        a.child_blocks.count.should == b.child_blocks.count
        a.condition.should == b.condition
      end

      it "return BlockData with all content and child inline blocks" do
        block_data = BlockParser.parse(@sample_block_helper.sample_block)
        compare_block_datas(block_data, @sample_block_helper.sample_block_data)
        compare_block_datas(block_data.child_blocks[0], @sample_block_helper.sample_block_data.child_blocks[0])
      end

    end

    describe "#find_files" do
    
      it "returns list of css and js files linked in block" do
        result = BlockParser.find_files(@sample_block_helper.construct_links_block(@styles, @scripts))
        (result[:css]- @styles).should be_empty
        (result[:js]- @scripts).should be_empty
      end

    end

  end
end
