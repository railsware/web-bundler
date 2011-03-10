require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::Filters::CompressFilter do
  before(:each) do
    @styles = [WebResourceBundler::ResourceFile.new_css_file('1.css', 
    <<-CONTENT
      a:link {
        text-decoration: none;
        background:url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA8gAAAATCAIAAADD') no-repeat 0 0;
        color: red; 
        font-size: 12pt;
      } 
    CONTENT
    )]
    @scripts = [WebResourceBundler::ResourceFile.new_css_file('1.css', '(function () { var foo={};foo["bar"]="baz"; })()')] 
  end

  subject do
    file_manager = FileManager.new(settings)
    WebResourceBundler::Filters::CompressFilter::Filter.new({:obfuscate_js => false}, file_manager)
  end

  describe "#new_css_path" do
    it "should return new css file path with prefix min" do
      subject.send(:new_css_path, '/images/1.css').should == '/images/min_1.css'
    end
  end

  describe "#new_css_path" do
    it "should return new js file path with prefix min" do
      subject.send(:new_js_path, '/images/1.js').should == '/images/min_1.js'
    end
  end

  describe "#compress_styles" do
    it "should compress css" do
      file = subject.send(:compress_styles!, @styles).first
      file.content.should == "a:link{text-decoration:none;background:url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA8gAAAATCAIAAADD') no-repeat 0 0;color:red;font-size:12pt}"
    end
  end

  describe "#compress_scripts" do
    it "should compress js" do
      file = subject.send(:compress_scripts!, @scripts).first
      file.content.should == "(function(){var foo={};foo.bar=\"baz\"})();"
    end
  end

  context "obfuscating setted to false" do

    subject do
      file_manager = FileManager.new(settings)
      WebResourceBundler::Filters::CompressFilter::Filter.new({:obfuscate_js => true}, file_manager)
    end

    describe "#compress_scripts" do
      it "should compress js" do
        file = subject.send(:compress_scripts!, @scripts).first
        file.content.should == "(function(){var a={};a.bar=\"baz\"})();"
      end
    end

  end
end

