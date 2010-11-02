require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
require 'digest/md5'
describe WebResourceBundler::Filters::BundleFilter::ResourcePackager do
    before(:each) do
      clean_public_folder
      @file_packager = Filters::BundleFilter::ResourcePackager.new @settings
      @file_paths = @styles.map do |url|
        File.join(@settings.resource_dir, url)
      end
      @css_resource = ResourceBundle::Data.new(ResourceBundle::CSS, @styles)
      @js_resource = ResourceBundle::Data.new(ResourceBundle::JS, @scripts)
    end

    describe "#bundle_files" do
      context "one of the files unexistent" do
        before(:each) do
          @files = [@styles[0], 'unexistent.css']
        end
        it "throws ResourceNotFoundError exception" do
          lambda { @file_packager.bundle_files(@files) }.should raise_error(WebResourceBundler::Exceptions::ResourceNotFoundError)
        end
      end
    end

    describe "#extract_imported_files!" do
      it "returns array of imported css files" do
        content = "@import 'styles/first.css';\n@import 'styles/skins/second.css';"
        @file_packager.extract_imported_files!(content)
        content.should == "\n"
      end
    end

    describe "#bundle_resource" do

      before(:each) do
        @filepath = File.join(@settings.resource_dir, @file_packager.bundle_resource(@css_resource))
      end

      it "creates bundle file from files passed with specific name" do
        File.exist?(@filepath).should be_true
      end

      it "creates bundle file containing all files content" do
        pending
        content = File.read(@filepath)
        p content
        @css_resource.files.each do |f|
          file_content = File.read(File.join(@settings.resource_dir, f))
          puts "####################"
          p file_content
          content.scan(file_content).size.should be_true
        end
      end

    end

  end

