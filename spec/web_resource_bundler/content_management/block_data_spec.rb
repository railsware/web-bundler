require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::BlockData do
  describe "#apply_filter" do
    it "applies filter to block_data, its childs, and theirs childs etc." do
      filter = mock("filter")
      block_data = @sample_block_helper.sample_block_data
      filter.should_receive(:apply).with(block_data)
      filter.should_receive(:apply).with(block_data.child_blocks.first)
      filters = [filter]
      block_data.apply_filters(filters)
    end
  end

  describe "#clone" do
    it "creates deep clone of block data" do
      block_data = @sample_block_helper.sample_block_data
      clon = block_data.clone
      block_data.object_id.should_not == clon.object_id
      block_data.css.object_id.should_not == clon.css.object_id
      block_data.js.object_id.should_not == clon.js.object_id
      child = block_data.child_blocks[0]
      child_copy = clon.child_blocks[0]
      child.object_id.should_not == child_copy.object_id 
      child.css.object_id.should_not == child_copy.css.object_id
      child.js.object_id.should_not == child_copy.js.object_id
    end
  end
end
