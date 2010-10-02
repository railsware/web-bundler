require File.join(File.dirname(__FILE__), "../spec_helper")
module WebResourcePackager
  describe BlockData do

    describe "#get_content" do
      
      it "return similar content when BlockData data is identical by means" do
        sample = sample_block_data
        sample.child_blocks = [child_block_data1, child_block_data2]
        similar = BlockData.new
        similar.inline_block = sample.inline_block
        similar.files = sample.files
        similar.child_blocks = sample.child_blocks.reverse
        similar.get_content.should == sample.get_content
      end

    end
  end
end
