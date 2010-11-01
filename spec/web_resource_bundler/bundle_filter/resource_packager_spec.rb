require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
require 'digest/md5'
describe WebResourceBundler::BundleFilter::ResourcePackager do
    before(:each) do
      clean_public_folder
      @file_packager = BundleFilter::ResourcePackager.new @settings
      @file_paths = @styles.map do |url|
        File.join(@settings.resource_dir, url)
      end
      @css_resource = ResourceBundle::Data.new(ResourceBundle::CSS, @styles)
      @js_resource = ResourceBundle::Data.new(ResourceBundle::JS, @scripts)
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

    describe "#bundle_file_path" do
      it "returns path of bundle file" do
        name = "sample_file.css"
        path = File.join(@settings.resource_dir, @settings.cache_dir, name) 
        @file_packager.bundle_file_path(name).should == path
      end
    end

    describe "#bundle_file_exist?" do
      it "return true if bundle file exist in resource dir" do
        @file_packager.bundle_resource(@css_resource)
        @file_packager.bundle_file_exist?(@css_resource.bundle_filename(@settings)).should be_true
      end
    end

  end

