require File.join(File.dirname(__FILE__), "../spec_helper")
module WebResourcePackager
  describe BlockFiles do

    describe "#get_content" do
      
      it "returns string with object content" do
        @@files1.get_content.should == (@@files1.css_files.sort + @@files1.js_files.sort).join('|')
      end

      it "returns unique content different for different BlockFiles data" do
        @@files1.get_content.should_not == @@files2.get_content
      end
      
      it "return similar content when BlockFiles data is identical by means" do
        similar = BlockFiles.new
        similar.css_files = @@files1.css_files.reverse
        similar.js_files = @@files1.js_files.reverse
        @@files1.get_content.should == similar.get_content
      end

    end
  end
end
