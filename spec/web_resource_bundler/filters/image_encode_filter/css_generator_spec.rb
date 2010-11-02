require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
module WebResourceBundler::Filters::ImageEncodeFilter
  describe CssGenerator do
    before(:each) do
      @generator = CssGenerator.new @settings
    end
    describe "#read_css_file" do
      it "should return nil if file not exist" do
        @generator.read_css_file("NonExistentFile.css").should be_nil
      end		

      it "should return file content if file exist and has css extension" do
        @generator.read_css_file(@styles.first).should_not be_nil
      end

      it "should return nil even if file exist but hasn't css extension" do
        @generator.read_css_file(__FILE__).should be_nil
      end	

    end
    
    describe "#pattern" do
      it "should match with correct original tags" do
        correct_values = ["#{CssGenerator::TAGS[0]}:url('temp/image.png');","  #{CssGenerator::TAGS[1]}\t  :\n  url('temp/image.png') ;"]
        correct_values.each do |v|
          v.should match(CssGenerator::PATTERN)	
        end
      end
      
      it "should not match with incorrect tags" do
        incorrect_values = ["handy_dandy_tag:url('goody/truly.png')","background-image:urlec('asd/asdf.gif');", 
        "background-imageis:url('asdf/asdf.jpg');}"]
        incorrect_values.each do |v|
          v.should_not match(CssGenerator::PATTERN)
        end
      end
    end
    
    describe "#encode_images_basic" do

      before(:each) do
        @content = "background-image: url('images/logo.jpg'); background: url(\"non_existent.jpg\");"
        @images = @generator.encode_images_basic(@content) do |image_data|
          image_data.extension
        end
      end

      it "substitute each image tag (image should exist and has proper size) with result of a yield" do
        @content.should == "jpg background: url(\"non_existent.jpg\");"
      end

      it "returns hash of images found and with proper size" do
        @images.size.should == 1
        @images['images/logo.jpg'].should be_an_instance_of(ImageData)
      end

    end
    
    describe "#new_filename" do
      it "should return new filename for css for all browsers except IE" do
        filename = "mycss.css"
        @generator.encoded_filename(filename).should == CssGenerator::FILE_PREFIX + filename
      end
    end

    describe "#new_filename_for_ie" do
      it "should return new filename for css for IE" do
        filename = "2.css"
        @generator.encoded_filename_for_ie(filename).should == CssGenerator::IE_FILE_PREFIX + filename
      end
    end

    describe "#encode_images" do
      it "creates file in cache dir with new name" do
        file = @styles.first
        fileurl = @generator.encode_images(file)
        File.exist?(File.join(@settings.resource_dir,fileurl)).should be_true
      end
    end
    
    describe "#encode_images_for_ie" do
      it "creates file in cache dir with new name and content for IE browser" do
        file = @styles.first
        fileurl = @generator.encode_images_for_ie(file)
        File.exist?(File.join(@settings.resource_dir, fileurl)).should be_true
      end
    end

    describe "#construct_mhtml_link" do
      it "should create link without public folder" do
        @generator.construct_mhtml_link("temp.css").should == "http://#{@settings.domain}/cache/temp.css"
      end
    end
  end
end

