require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
module WebResourceBundler::Filters::ImageEncodeFilter
  describe CssGenerator do
    before(:each) do
      @generator = CssGenerator.new(@settings, FileManager.new(@settings))
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
        result = @generator.encode_images_basic(@content) do |image_data|
          image_data.extension
        end
        @images = result[:images]
        @content = result[:content]
      end

      it "substitute each image tag (image should exist and has proper size) with result of a yield" do
        @content.should == "jpg; background: url(\"non_existent.jpg\");"
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
        pending
        file = @styles.first
        fileurl = @generator.encode_images(file)
      end
    end
    
    describe "#encode_images_for_ie" do
      it "creates file in cache dir with new name and content for IE browser" do
        pending
        file = @styles.first
        fileurl = @generator.encode_images_for_ie(file)
      end
    end

    describe "#construct_mhtml_link" do
      it "should create link without public folder" do
        @generator.construct_mhtml_link("temp.css").should == "http://#{@settings.domain}/cache/temp.css"
      end
    end
  end
end

