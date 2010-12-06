require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
module WebResourceBundler::Filters::ImageEncodeFilter
  describe CssGenerator do
    before(:each) do
      @settings = Settings.new base64_settings
      @generator = CssGenerator.new(@settings, FileManager.new(@settings.resource_dir, @settings.cache_dir))
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
        @content = "background-image: url('images/ligo.jpg'); background: url('images/logo.jpg');"
        @images = @generator.encode_images_basic!(@content) do |image_data, tag|
          tag + image_data.extension
        end
      end

      it "substitute each image tag (image should exist and has proper size) with result of a yield" do
        @content.should == "background-image: url('images/ligo.jpg'); background: jpg;"
      end

      it "returns hash of images found and with proper size" do
        @images.size.should == 1
        @images['images/logo.jpg'].should be_an_instance_of(ImageData)
      end

    end

    context "no images in css file" do
      before(:each) do
        @path = 'path'
        @content = 'margin: 10px;'
        @file = WebResourceBundler::ResourceFile.new_css_file(@path, @content)
      end
      describe "#encode_images!" do
        it "content isn't changed if no images found" do
          images = @generator.encode_images!(@file.content)
          @file.content.should == @content
          images.should be_empty
        end
              end
      describe "#encode_images_for_ie" do
        it "returns original content if no images found" do
          @generator.encode_images_for_ie!(@file.content, 'cache/1.mhtml')
          @file.content.should == @content
        end
        
      end
    end
    context "css files has images" do
      before(:each) do
        @path = 'style.css' 
        @content = "background: #eeeeee url('images/logo.jpg') repeat-x 0 100%;" 
        @file = WebResourceBundler::ResourceFile.new_css_file(@path, @content)
      end
      describe "#encode_images" do
        it "return images hash" do
          images = @generator.encode_images!(@content)
          images.size.should == 1
        end

        it "modifies content with encoded images" do
          @generator.encode_images!(@file.content)
          @file.content.include?("background: #eeeeee url('data:image").should be_true
          @file.content.include?("repeat-x 0 100%").should be_true
        end
      end
      describe "#encode_images_for_ie" do
        it "changes urls to mhtml link" do
          @generator.encode_images_for_ie!(@content, 'cache/1.mhtml')
          @content.include?("mhtml:#{@settings.protocol}://#{@settings.domain}/cache/1.mhtml!").should be_true
          @content.include?("*background: #eeeeee url(mhtml:").should be_true
          @content.include?("repeat-x 0 100%").should be_true
        end
      end
    end
    
    describe "#construct_mhtml_link" do
      it "should create link without public folder" do
        @generator.construct_mhtml_link("temp.css").should == "http://#{@settings.domain}/temp.css"
      end
    end
  end
end

