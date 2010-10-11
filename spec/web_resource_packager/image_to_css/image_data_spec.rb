require File.join(File.dirname(__FILE__), "/../../spec_helper")
module ImageToCss
	describe ImageData do
		context "with non existent file" do

			before(:each) do
				@data = ImageData.new("NonExistentFile", "some_folder")		
			end

			it "should have exist property false" do
				@data.exist.should be_false	
			end 
			
			it "should return nil when encoded" do
				@data.encoded.should be_nil
			end
			
			it "should not be small enough" do
				@data.small_enough?.should_not be_true
			end
			
			it "should not have id and extension" do
				@data.id.should be_nil
				@data.extension.should be_nil
			end

		end

		context "with existent small enough file" do
			before(:each) do
				@data = ImageData.new("../../public/images/logo.jpg",File.dirname(__FILE__))
			end
			
			it "should exist" do
				@data.exist.should be_true
			end

			it "should be small enough" do
				@data.should be_small_enough
			end
			
			it "should have id and extension" do
				@data.id.should_not be_nil
				@data.extension.should_not be_nil
			end
			
			it "should return some text when encoded" do
				@data.encoded.should_not be_nil
			end

			it "should have unique id" do
				new_data = ImageData.new("../../public/images/good.jpg",File.dirname(__FILE__))
				new_data.exist.should be_true
				@data.id.should_not equal(new_data.id)
  		end

			describe "#construct_mthml_image_data" do
				it "should return proper data" do
					result = CssFileGenerator::SEPARATOR + "\n" +
					"Content-Location:" + @data.id  + "\n" + 
					"Content-Transfer-Encoding:base64" + "\n" +
					@data.encoded + "\n\n"
					@data.construct_mhtml_image_data(CssFileGenerator::SEPARATOR).should == result
				end
			end
				
		end

		context "with too big image" do
			before(:each) do
				@data = ImageData.new("../../public/images/too_big_image.jpg",File.dirname(__FILE__))
			end
			it "should be too big" do
				@data.exist.should be_true		
				@data.should_not be_small_enough
			end
			it "should return nil when encoded" do
				@data.exist.should be_true		
				@data.encoded.should be_nil
			end
		end
		
	end
end
