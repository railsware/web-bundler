require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::BlockData do

  before(:each) do
    @block_data = @sample_block_helper.sample_block_data
  end

  describe "#styles" do
    it "should return all files with 'css' extension" do
      @block_data.styles.each do |file|
        File.basename(file.path).split('.')[-1].should == 'css'
      end
    end
  end

  describe "#scripts" do
    it "should return all files with 'js' extension" do
      @block_data.scripts.each do |file|
        File.basename(file.path).split('.')[-1].should == 'js'
      end
    end
  end

  describe "#mhtml_styles" do
    it "should return all files with 'js' extension" do
      @block_data.files = @block_data.files[0..2]
      @block_data.files.first.type = WebResourceBundler::ResourceFileType::MHTML_CSS
      @block_data.files[1].type = WebResourceBundler::ResourceFileType::CSS
      @block_data.files.last.type = WebResourceBundler::ResourceFileType::MHTML
      @block_data.mhtml_styles.size.should == 3
    end
  end

  describe "#base64_styles" do
    it "should return all files with 'js' extension" do
      @block_data.files = @block_data.files[0..1]
      @block_data.files.first.type = WebResourceBundler::ResourceFileType::BASE64_CSS
      @block_data.files.last.type = WebResourceBundler::ResourceFileType::CSS
      @block_data.base64_styles.size.should == 2
    end
  end

  describe "#scripts" do
    it "should return all files with 'js' extension" do
      @block_data.scripts.each do |file|
        File.basename(file.path).split('.')[-1].should == 'js'
      end
    end
  end

  describe "#apply_filter" do
    it "applies filter to block_data, its childs, and theirs childs etc." do
      filter = mock("filter")
      filter.should_receive(:apply!).with(@block_data)
      filter.should_receive(:apply!).with(@block_data.child_blocks.first)
      filters = [filter]
      @block_data.apply_filters(filters)
    end
  end

  describe "#all_childs" do
    it "creates array of block data and all its childs recursively" do
      BlockData.all_childs(@block_data).size.should == 2
    end
  end

  describe "#clone" do
    it "creates deep clone of block data" do
      clon = @block_data.clone
      @block_data.object_id.should_not == clon.object_id
      ((@block_data.files.map { |f| f.object_id })& clon.files.map {|f| f.object_id}).should be_empty
      child = @block_data.child_blocks[0]
      child_copy = clon.child_blocks[0]
      child.object_id.should_not == child_copy.object_id 
      ((child.files.map { |f| f.object_id }) & child_copy.files.map {|f| f.object_id}).should be_empty
    end
  end
end
