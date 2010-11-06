require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
module WebResourceBundler
  describe BlockParser do

    before(:each) do
      @file_manager = FileManager.new @settings
      @block_parser = BlockParser.new
    end

    #pattern testing
    it "matches with different conditional comments" do
      tests = ['<!--[if lte IE 7]>...<![endif]-->','<!--[if !(IE 7)]>...<![endif]-->',
        '<!--[if IE]>...<![endif]-->']
      tests.each do |test|
        BlockParser::CONDITIONAL_BLOCK_PATTERN.match(test).should be_true
      end
    end

    describe "#remove_links" do
      it "deletes all links to resources (js, css) from block" do
        block = @sample_block_helper.construct_links_block(@styles, @scripts)
        block += @sample_block_helper.sample_inline_block
        block += @sample_block_helper.construct_links_block(@styles, @scripts)
        block += @sample_block_helper.sample_inline_block
        @block_parser.remove_links(block).should == @sample_block_helper.sample_inline_block + @sample_block_helper.sample_inline_block
      end
    end

    describe "#parse" do

      it "returns BlockData object" do
        @block_parser.parse("").is_a?(BlockData).should be_true
      end

      it "returns empty BlockData when block is empty" do
        data = @block_parser.parse("")
        data.css.files.should be_empty
        data.js.files.should be_empty
      end


      def compare_block_datas(a,b)
        (a.css.files.keys - b.css.files.keys).should be_empty
        (a.js.files.keys - b.js.files.keys).should be_empty
        a.child_blocks.size.should == b.child_blocks.size
        a.condition.should == b.condition
      end

      it "return BlockData with all content and child inline blocks" do
        block_data = @block_parser.parse(@sample_block_helper.sample_block)
        compare_block_datas(block_data, @sample_block_helper.sample_block_data)
        compare_block_datas(block_data.child_blocks[0], @sample_block_helper.sample_block_data.child_blocks[0])
      end

    end

    describe "#find_files" do
    
      it "returns list of css and js files linked in block" do
        result = @block_parser.find_files(@sample_block_helper.construct_links_block(@styles, @scripts))
        
        (result[:css].keys - @styles).should be_empty
        (result[:js].keys - @scripts).should be_empty
      end

    end

  end
end
