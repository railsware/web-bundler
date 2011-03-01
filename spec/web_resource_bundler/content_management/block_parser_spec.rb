require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
module WebResourceBundler
  describe BlockParser do

    before(:each) do
      @settings = settings
      @file_manager = FileManager.new(@settings)
      @block_parser = BlockParser
    end

    #conditional comment spec
    it "matches with different conditional comments" do
      tests = ['<!--[if lte IE 7]>...<![endif]-->','<!--[if !(IE 7)]>...<![endif]-->',
        '<!--[if IE]>...<![endif]-->']
      tests.each do |test|
        BlockParser::CONDITIONAL_BLOCK_PATTERN.should match(test)
      end
    end

    #links pattern spec
    it "matches with css or js link" do
      tests = ["\<link href='\/cache\/style.css' \/\>","\<script src='\/cache\/script.js' \/script\>"]
      tests.each do |link|
        BlockParser::LINK_PATTERN.should match(link)
      end
    end

    describe "#remove_links" do
      it "deletes all links to resources (js, css) from block" do
        block = @sample_block_helper.construct_links_block(styles, scripts)
        block += @sample_block_helper.sample_inline_block
        block += @sample_block_helper.construct_links_block(styles, scripts)
        block += @sample_block_helper.sample_inline_block
        @block_parser.send(:remove_links, block).should == @sample_block_helper.sample_inline_block + @sample_block_helper.sample_inline_block
      end

      it "doesn't delete links to non js or css resource, like favicon for example" do
        text = "<link href='1.css' /><link rel='shortcut icon' href='/favicon.ico' />"
        @block_parser.send(:remove_links, text).should == "<link rel='shortcut icon' href='/favicon.ico' />"
      end

      it "doesn't touch remote resources" do
        text = "<link href='http://google.com/1.css' type='text/css' rel='stylesheet' />"
        @block_parser.send(:remove_links, text).include?(text).should be_true
      end
    end

    describe "#parse" do

      it "returns BlockData object" do
        @block_parser.parse("").is_a?(BlockData).should be_true
      end

      it "returns empty BlockData when block is empty" do
        data = @block_parser.parse("")
        data.files.should be_empty
      end

      def compare_block_datas(a,b)
        a.files.size.should == b.files.size
        (a.files.map {|f| f.path} - b.files.map{|f| f.path}).should be_empty
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
    
      it "returns array of css and js files linked in block" do
        result = @block_parser.send(:find_files, @sample_block_helper.construct_links_block(styles, scripts))
        files = styles + scripts
        result.each do |f|
          files.include?(f.path).should be_true
        end
      end

      it "recognize only css and js files" do
        block = "<link href='/rss.atom' /> <link href='valid.css' />"
        result = @block_parser.send(:find_files, block)
        result.first.path.should == 'valid.css'
      end

      it "recognize files only on disk, not full urls" do
        block = "<link href='http://glogle.com/web.css' /> <link href='valid.css' />"
        result = @block_parser.send(:find_files, block)
        result.first.path.should == 'valid.css'
      end

    end

    describe "#create_resource_file" do
      it "returns nil if attributes not src or href" do
        @block_parser.send(:create_resource_file, 'invalid', '1.jpg').should == nil
      end
      it "returns nil if file isn't css or js" do
        @block_parser.send(:create_resource_file, 'href', '1.cssI').should == nil
        @block_parser.send(:create_resource_file, 'src', '1.jsI').should == nil
      end
      it "returns correct ResourceFile if conditions met" do
        @block_parser.send(:create_resource_file, 'href', '1.css').path.should == '1.css' 
        @block_parser.send(:create_resource_file, 'src', '1.js').path.should == '1.js'
      end
    end

  end

  
end
