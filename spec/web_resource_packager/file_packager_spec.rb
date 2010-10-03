require File.join(File.dirname(__FILE__), "../spec_helper")
module WebResourcePackager
  describe FilePackager do

    before(:each) do
      @test_dir = File.absolute_path(File.join(File.dirname(__FILE__), "../public"))
      @file_packager = FilePackager.new @test_dir      
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


    describe "#get_imported_file_path" do
      it "returns imported file path using parent file path" do

      end
    end


  end
end

