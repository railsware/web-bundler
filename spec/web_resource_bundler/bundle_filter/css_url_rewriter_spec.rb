require File.absolute_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::BundleFilter::CssUrlRewriter do
  describe "#rewrite_relative_path" do
    it "returns absolute path using url and css file path" do
      tests = {
        "../image.gif" => "/styles/image.gif",
        "./image.gif" => "/styles/skin/image.gif",
        "../../image.gif" => "/image.gif"
      }
      css_file_path = "/styles/skin/1.css"
      tests.each do |key, value|
        BundleFilter::CssUrlRewriter.rewrite_relative_path(css_file_path, key).should == value 
      end
    end
  end
  describe "#rewrite_content_urls" do
    it "rewrites all urls in css block" do
      css = "abracada: url\t('../image.gif'); \n backaground-image: url(\"../../image.gif\");"
      result = "abracada: url('\/styles\/image.gif'); \n backaground-image: url('\/image.gif');"
      BundleFilter::CssUrlRewriter.rewrite_content_urls("/styles/skin/1.css", css).should == result
    end
  end
end

