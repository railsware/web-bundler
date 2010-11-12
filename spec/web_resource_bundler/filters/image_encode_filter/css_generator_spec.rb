require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
module WebResourceBundler::Filters::ImageEncodeFilter
  describe CssGenerator do
    before(:each) do
      @settings = Settings.new @base64_settings
      @generator = CssGenerator.new(@settings, FileManager.new(@settings))
    end
    
    describe "#pattern" do
      it "should match with correct original tags" do
        correct_values = ["#{CssGenerator::TAGS[0]}:url('temp/image.png');",
          "  #{CssGenerator::TAGS[1]}\t  :\n  url('temp/image.png') ;",
          "background:url('temp/1.png') repeat 0 0;"]
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
        @content = "background-image: url('images/logo.jpg'); background: url('images/logo.jpg'); background: url(\"non_existent.jpg\");"
        result = @generator.encode_images_basic(@content) do |image_data, tag|
          tag + image_data.extension
        end
        @images = result[:images]
        @content = result[:content]
      end

      it "substitute each image tag (image should exist and has proper size) with result of a yield" do
        @content.should == "background-image: jpg; background: jpg; background: url(\"non_existent.jpg\");"
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

    context "no images in css file" do
      before(:each) do
        @path = 'path'
        @content = 'margin: 10px;'
        @result = {@path => @content}
      end
      describe "#encode_images" do
        it "returns original content if no images found" do
          @generator.encode_images(@path, @content).should == @result
        end
      end
      describe "#encode_images_for_ie" do
        it "returns original content if no images found" do
          @generator.encode_images_for_ie(@path, @content).should == @result 
        end
      end
    end
    context "css files has images" do
      before(:each) do
        @path = 'style.css' 
        @content = "background: #eeeeee url('images/logo.jpg') repeat-x 0 100%;" 
      end
      describe "#encode_images" do
        it "returns hash with new file path and images encoded in content" do
          result = @generator.encode_images(@path, @content)
          new_path = result.keys[0]
          new_path.should == 'base64_' + File.basename(@path)
          result[new_path].include?("background: #eeeeee url('data:image").should be_true
          result[new_path].include?("repeat-x 0 100%").should be_true
        end
      end
      describe "#encode_images_for_ie" do
        it "returns hash with new file path and images encoded in content" do
          result = @generator.encode_images_for_ie(@path, @content)
          new_path = result.keys[0]
          new_path.should == 'base64_ie_' + File.basename(@path)
          result[new_path].include?("background: #eeeeee url(mhtml:").should be_true
          result[new_path].include?("repeat-x 0 100%").should be_true
        end
      end
    end
    
    describe "#construct_mhtml_link" do
      it "should create link without public folder" do
        @generator.construct_mhtml_link("temp.css").should == "http://#{@settings.domain}/cache/temp.css"
      end
    end
  end
end

