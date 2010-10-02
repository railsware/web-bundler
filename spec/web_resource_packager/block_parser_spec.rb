require File.join(File.dirname(__FILE__), "../spec_helper")
module WebResourcePackager
  describe BlockParser do

    describe "#remove_links" do
      it "deletes all links to resources (js, css) from block" do
        block = construct_links_block(@@styles, @@scripts)
        block += sample_inline_block
        block += construct_links_block(@@styles, @@scripts)
        block += sample_inline_block
        BlockParser.remove_links(block).should == sample_inline_block + sample_inline_block
      end
    end

    describe "#parse" do

      it "returns BlockData object" do
        BlockParser.parse("").is_a?(BlockData).should be_true
      end

      def block_files_empty?(block_files)
        block_files.css_files.empty? and block_files.js_files.empty?
      end

      it "returns empty BlockData when block is empty" do
        data = BlockParser.parse("")
        block_files_empty?(data.files).should be_true
      end
      
      def compare_block_datas(a,b)
        (a.files.css_files - b.files.css_files).should be_empty
        (a.files.js_files - b.files.js_files).should be_empty
        a.child_blocks.count.should == b.child_blocks.count
        a.condition.should == b.condition
      end

      it "return BlockData with all content and child inline blocks" do
        block_data = BlockParser.parse(sample_block)
        compare_block_datas(block_data, sample_block_data)
        compare_block_datas(block_data.child_blocks[0], sample_block_data.child_blocks[0])
      end

    end

    describe "#find_files" do
    
      it "returns list of css and js files linked in block" do
        result = BlockParser.find_files(construct_links_block(@@styles, @@scripts))
        (result.css_files - @@styles).should be_empty
        (result.js_files - @@scripts).should be_empty
      end

    end

  end
end
