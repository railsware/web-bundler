require File.join(File.dirname(__FILE__), "../spec_helper")
require 'digest/md5'
module WebResourcePackager
  describe FilePackager do

    describe "with correct dirname" do

      before(:each) do
        @test_dir = File.absolute_path(File.join(File.dirname(__FILE__), "../public"))
        @settings = Settings.new(@@settings_hash)
        @file_packager = FilePackager.new @test_dir, @settings
        @file_urls = ['styles/sample.css', 'styles/temp.css']
        @file_paths = @file_urls.map do |url|
          File.join(@test_dir, url)
        end
        @bundle = File.read(File.join(File.dirname(__FILE__), '../public/styles/bundle.css'))
      end

      describe "#get_absolute_file_path" do
        it "returns absolute file path using url from css/js/html" do
          (0...@file_urls.count).each do |i|
            @file_packager.get_absolute_file_path(@file_urls[i]).should == @file_paths[i]
          end
        end
      end

      describe "#bundle_files" do
        it "bundle files in one chunk" do
          result = File.read("/home/gregolsen/result.css")
          @file_packager.bundle_files(@file_urls).should == result
        end
      end

      describe "#get_md5" do
        it "returns md5 from filenames and else additional data" do
          items = [@@styles, @settings.domen, @settings.protocol]
          @file_packager.get_md5(@@styles).should == Digest::MD5.hexdigest(items.flatten.join('|'))
        end
      end

      describe "#get_bundle_file_name" do
        it "returns filename of bundle constructed from passed files" do
          name = Resource::CSS[:name] + '_' + @file_packager.get_md5(@@styles) + '.' + @settings.language + '.' + Resource::CSS[:ext] 
          @file_packager.get_bundle_file_name(Resource::CSS, @@styles).should == name 
        end
      end

      describe "#get_bundle_file_path" do
        it "returns bundle file path" do
          @file_packager.get_bundle_file_path(@file_packager.get_bundle_file_name(Resource::CSS, @@styles)).should == File.join(@test_dir, FilePackager::CACHE_DIR,@file_packager.get_bundle_file_name(Resource::CSS, @@styles))   
        end
      end

      describe "#create_bundle" do
        it "creates file bundle file with specific name" do
          @file_packager.create_bundle(Resource::CSS, @@styles)
          filepath = @file_packager.get_bundle_file_path(@file_packager.get_bundle_file_name(Resource::CSS, @@styles))
          puts filepath
          File.exist?(filepath).should be_true
        end
      end

    end

    describe "with incorrect directory passed" do
      before(:each) do
        @file_packager = FilePackager.new('incorrect/dir/name', Settings.new)
      end

    end

  end
end

