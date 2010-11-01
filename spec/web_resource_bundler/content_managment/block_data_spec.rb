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
end
