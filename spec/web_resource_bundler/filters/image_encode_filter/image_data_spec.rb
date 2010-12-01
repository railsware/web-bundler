require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
module WebResourceBundler::Filters::ImageEncodeFilter
	describe ImageData do
    def image_path(filename)
      File.join("/images", filename)
    end

		context "with non existent file" do

		  it "raises NonExistentCssImage exception" do
        lambda { ImageData.new("NonExistentFile", "some_folder") }.should raise_error(WebResourceBundler::Exceptions::NonExistentCssImage)
      end

      it "doesn't raise exception if image url is absolute but exist should be false" do
        ImageData.new("http://google.com/1.png", "some_folder").exist.should == false
      end

		end

		context "with existent small enough file" do
			before(:each) do
				@data = ImageData.new(image_path("logo.jpg"), settings.resource_dir)
			end
			
			it "should exist" do
				@data.exist.should be_true
			end

			it "should have id and extension" do
				@data.id.should_not be_nil
				@data.extension.should_not be_nil
			end
			
			it "should return some text when encoded" do
				@data.encoded.should_not be_nil
			end

			it "should have unique id" do
				new_data = ImageData.new(image_path("good.jpg"), settings.resource_dir)
				new_data.exist.should be_true
				@data.id.should_not equal(new_data.id)
  		end

			describe "#construct_mthml_image_data" do
				it "should return proper data" do
					result = '--' + CssGenerator::SEPARATOR + "\n" +
					"Content-Location:" + @data.id  + "\n" + 
					"Content-Transfer-Encoding:base64" + "\n\n" +
					@data.encoded + "\n\n"
					@data.construct_mhtml_image_data('--' + CssGenerator::SEPARATOR).should == result
				end
			end
				
		end

  end
end
