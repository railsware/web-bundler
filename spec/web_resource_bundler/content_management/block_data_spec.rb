require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::BlockData do
  describe "#apply_filter" do
    it "applies filter to block_data, its childs, and theirs childs etc." do
      filter = mock("filter")
      block_data = @sample_block_helper.sample_block_data
      filter.should_receive(:apply!).with(block_data)
      filter.should_receive(:apply!).with(block_data.child_blocks.first)
      filters = [filter]
      block_data.apply_filters(filters)
    end
  end

  describe "#all_childs" do
    it "creates array of block data and all its childs recursively" do
      block_data = @sample_block_helper.sample_block_data
      BlockData.all_childs(block_data).size.should == 2
    end
  end

  describe "#clone" do
    it "creates deep clone of block data" do
      block_data = @sample_block_helper.sample_block_data
      clon = block_data.clone
      block_data.object_id.should_not == clon.object_id
      ((block_data.files.map { |f| f.object_id })& clon.files.map {|f| f.object_id}).should be_empty
      child = block_data.child_blocks[0]
      child_copy = clon.child_blocks[0]
      child.object_id.should_not == child_copy.object_id 
      ((child.files.map { |f| f.object_id }) & child_copy.files.map {|f| f.object_id}).should be_empty
    end
  end
end
