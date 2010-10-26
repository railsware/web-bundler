require File.expand_path(File.join(File.dirname(__FILE__), "../spec_helper"))
describe WebResourceBundler::CssUrlRewriter do
  describe "#rewrite_relative_path" do
    it "returns absolute path using url and css file path" do
      tests = {
        "../image.gif" => "/styles/image.gif",
        "./image.gif" => "/styles/skin/image.gif",
        "../../image.gif" => "/image.gif",
        "../.././1.gif" => '/1.gif',
        '.././../styles/./../styles/3.jpg' => '/styles/3.jpg'
      }
      css_file_path = "/styles/skin/1.css"
      tests.each do |key, value|
        CssUrlRewriter.rewrite_relative_path(css_file_path, key).should == value 
      end
    end
  end
  describe "#rewrite_content_urls" do
    it "rewrites all urls in css block" do
      css = "abracada: url\t('../image.gif'); \n backaground-image: url(\"../../image.gif\");background: url(./i/backgrounds/menu.png) repeat-x 0 100%; }"
      result = "abracada: url('\/styles\/image.gif'); \n backaground-image: url('\/image.gif');background: url('/styles/skin/i/backgrounds/menu.png') repeat-x 0 100%; }"
      CssUrlRewriter.rewrite_content_urls("/styles/skin/1.css", css).should == result
    end
  end

end

