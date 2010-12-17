require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::ResourceFile do
  describe "#new_css_file" do
    it "creates new resource file of css type" do
      f = WebResourceBundler::ResourceFile.new_css_file('a', 'b')
      f.path.should == 'a'
      f.content.should == 'b'
      f.types.first.should == WebResourceBundler::ResourceFileType::CSS
    end
  end
  describe "#new_js_file" do
    it "creates new resource file of css type" do
      f = WebResourceBundler::ResourceFile.new_js_file('a', 'b')
      f.path.should == 'a'
      f.content.should == 'b'
      f.types.first.should == WebResourceBundler::ResourceFileType::JS
    end
  end
  describe "#new_mhtml_file" do
    it "creates new resource file of mhtml type" do
      f = WebResourceBundler::ResourceFile.new_mhtml_file('a', 'b')
      f.path.should == 'a'
      f.content.should == 'b'
      f.types.first.should == WebResourceBundler::ResourceFileType::MHTML
    end
  end
  describe "#new_style_file" do
    it "creates new resource file of CSS and IE_CSS type" do
      f = WebResourceBundler::ResourceFile.new_style_file('a', 'b')
      f.path.should == 'a'
      f.content.should == 'b'
      f.types.should == [WebResourceBundler::ResourceFileType::CSS, WebResourceBundler::ResourceFileType::IE_CSS]
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

