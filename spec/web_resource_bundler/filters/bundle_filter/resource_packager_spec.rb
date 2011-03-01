require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
require 'digest/md5'
describe WebResourceBundler::Filters::BundleFilter::ResourcePackager do
  before(:each) do
    @settings = settings
    file_manager = FileManager.new(@settings)
    @file_packager = Filters::BundleFilter::ResourcePackager.new(@settings, file_manager)
    @file_paths = styles.map do |url|
      File.join(@settings[:resource_dir], url)
    end
  end

  describe "#extract_imported_files!" do
    it "returns array of imported css files" do
      content = "@import 'import/first.css';\n@import 'import/second.css';"
      imported_files = @file_packager.send(:extract_imported_files!, content, 'styles/base.css')
      content.should == "\n"
      imported_files.should == ['styles/import/first.css', 'styles/import/second.css']
    end
  end

  describe "#build_imported_files" do
    it "should return css resource files" do
      files = @file_packager.send(:build_imported_files, styles)
      files.each do |file|
        styles.include?(file.path).should be_true
      end
    end
    it "should return empty array if paths are not css" do
      files = @file_packager.send(:build_imported_files, scripts)
      files.should be_empty
    end
  end

  describe "#bundle_files" do
    it "throws ResourceNotFoundError exception if one of imported files not found" do
      #creating file with content with imported unexistent files
      files = [WebResourceBundler::ResourceFile.new_css_file('styles/base.css', "@import 'import/first.css';\n@import 'import/second.css';")]
      lambda { @file_packager.bundle_files(files) }.should raise_error(Exceptions::ResourceNotFoundError) 
    end
    
    it 'should bundle files in original order' do
      files = [
        WebResourceBundler::ResourceFile.new_js_file('files/jquery.js', 'JQUERY_FILE'),
        WebResourceBundler::ResourceFile.new_js_file('files/jquery.carousel.js','JQUERY_CAROUSEL_FILE')
      ]
      result = @file_packager.bundle_files(files)
      (result =~ /JQUERY_FILE/).should < (result =~ /JQUERY_CAROUSEL_FILE/)
    end
    
  end

end

