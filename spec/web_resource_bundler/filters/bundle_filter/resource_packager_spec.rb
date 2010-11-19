require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
require 'digest/md5'
describe WebResourceBundler::Filters::BundleFilter::ResourcePackager do
  before(:each) do
    clean_public_folder
    file_manager = FileManager.new @settings
    @file_packager = Filters::BundleFilter::ResourcePackager.new(@settings, file_manager)
    @file_paths = @styles.map do |url|
      File.join(@settings.resource_dir, url)
    end
    
  end

  describe "#extract_imported_files!" do
    it "returns array of imported css files" do
      content = "@import 'import/first.css';\n@import 'import/second.css';"
      imported_files = @file_packager.extract_imported_files!(content, 'styles/base.css')
      content.should == "\n"
      imported_files.should == ['styles/import/first.css', 'styles/import/second.css']
    end
  end

  describe "#bundle_files" do
    it "throws ResourceNotFoundError exception if one of imported files not found" do
      #creating file with content with imported unexistent files
      files = {'styles/base.css' => "@import 'import/first.css';\n@import 'import/second.css';"}
      lambda { @file_packager.bundle_files(files) }.should raise_error(Exceptions::ResourceNotFoundError) 
    end
    
    it 'should bundle files in original order' do
      result = @file_packager.bundle_files({'files/jquery.js' => 'JQUERY_FILE', 'files/jquery.carousel.js' => 'JQUERY_CAROUSEL_FILE'})
      (result =~ /JQUERY_FILE/).should < (result =~ /JQUERY_CAROUSEL_FILE/)
    end
    
  end

end

