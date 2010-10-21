require File.absolute_path(File.join(File.dirname(__FILE__), "/../spec_helper"))
describe WebResourceBundler::BlockConstructor do
  describe "#construct_css_link" do
    it "constructs proper html link to css file" do
      BlockConstructor.construct_css_link('/styles/1.css').should == "<link href = \"/styles/1.css\" media=\"screen\" rel=\"Stylesheet\" type=\"text/css\" />"
    end
  end

  describe "#construct_css_link" do
    it "constructs proper html link to js file" do
      BlockConstructor.construct_js_link('/scripts/cool.js').should == "<script src = \"/scripts/cool.js\" type=\"text/javascript\"></script>"
    end
  end

  describe "#construct_block" do
    it "constructs html block using block data structure" do
      pending
      block_data = @sample_block_helper.sample_block_data
      sample_block = @sample_block_helper.sample_block
      result = BlockConstructor.construct_block(block_data)
    end
  end

end
