require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::ResourceFile do
  describe "#new_css_file" do
    it "creates new resource file of css type" do
      f = WebResourceBundler::ResourceFile.new_css_file('a', 'b')
      f.path.should == 'a'
      f.content.should == 'b'
      f.type.should == WebResourceBundler::ResourceFileType::CSS
    end
  end
  describe "#new_js_file" do
    it "creates new resource file of js type" do
      f = WebResourceBundler::ResourceFile.new_js_file('a', 'b')
      f.path.should == 'a'
      f.content.should == 'b'
      f.type.should == WebResourceBundler::ResourceFileType::JS
    end
  end
  describe "#new_mhtml_css_file" do
    it "creates new resource file of mhtml css type" do
      f = WebResourceBundler::ResourceFile.new_mhtml_css_file('a', 'b')
      f.path.should == 'a'
      f.content.should == 'b'
      f.type.should == WebResourceBundler::ResourceFileType::MHTML_CSS
    end
  end
  describe "#clone" do
    it "creates full clone of resource file object" do
      f = WebResourceBundler::ResourceFile.new_css_file('a', 'b')
      clon = f.clone
      f.object_id.should_not == clon.object_id
      f.path.object_id.should_not == clon.path.object_id
      f.content.object_id.should_not == clon.content.object_id
    end
  end
end

