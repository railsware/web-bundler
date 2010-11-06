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
      pending
      files = {'styles/base.css' => "@import 'import/first.css';\n@import 'import/second.css';"}
      @file_packager.bundle_files(files).should raise_error 
    end
  end

end
