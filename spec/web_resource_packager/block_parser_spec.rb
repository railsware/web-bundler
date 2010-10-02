require File.join(File.dirname(__FILE__), "../spec_helper")
module WebResourcePackager
  describe BlockParser do

    def construct_js_link(path)
      "<script src = \"#{path}\" type=\"text/javascript\"></script>"
    end

    def construct_css_link(path)
      "<link href = \"#{path}\" media=\"screen\" rel=\"Stylesheet\" type=\"text/css\" />"
    end

    def sample_inline_block
      "this is inline block content" +
          "<script>abracadabra</script><style>abracadabra</style>"
    end

    def construct_links_block(styles, scripts)
      block = ""
      styles.each do |path|
        block += construct_css_link(path)
      end
      scripts.each do |path|
        block += construct_js_link(path)
      end
      block
    end

    @@styles = ["/styles/1.css","/boo/goo.css", "/f3/e3/sdf.css", "/styles/abc.css"]
    @@scripts = ["/scripts/13.js", "/scripts/my_script.js", "/foo/boo.js", "/goo/doo.js"]
    @@first_part_block_files = BlockFiles.new(@@scripts[0..1],@@styles[0..1])
    @@second_part_block_files = BlockFiles.new(@@scripts[2..3],@@styles[2..3])

    def sample_cond_block
      "<!-- [if IE 7] >" +
      construct_links_block(@@styles[2..3], @@scripts[2..3]) +
      sample_inline_block +
      "<! [endif] -->"
    end

    def sample_block_data
      data = BlockData.new(nil) 
      data.files = @@first_part_block_files
      data.inline_block = sample_inline_block
      child = BlockData.new("[if IE 7]")
      child.files = @@second_part_block_files
      child.inline_block = sample_inline_block
      data.child_blocks << child
      data
    end

    def sample_block
      block = construct_links_block(@@styles[0..1], @@scripts[0..1]) + "\n"
      block += sample_inline_block
      block += sample_cond_block
    end

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
