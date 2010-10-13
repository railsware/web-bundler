require File.join(File.dirname(__FILE__), "/../../spec_helper")
module ImageEncodeFilter
  describe CssGenerator do
    describe "#read_css_file" do
      it "should return nil if file not exist" do
        CssGenerator.read_css_file("NonExistentFile.css").should be_nil
      end		

      it "should return file content if file exist and has css extension" do
        CssGenerator.read_css_file(File.join(File.dirname(__FILE__), "../../public/sample.css")).should_not be_nil
      end

      it "should return nil even if file exist but hasn't css extension" do
        CssGenerator.read_css_file(File.absolute_path(__FILE__)).should be_nil
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
    
    describe "#iterate_through_matches" do
      it "should give strings that matches to pattern" do
        data = File.read(File.join(File.dirname(__FILE__), "../../public/sample.css"))
        CssGenerator.iterate_through_matches(data, CssGenerator::PATTERN) do |s|
          s.should match(CssGenerator::PATTERN)
        end
      end 
    end
    
    describe "#new_filename" do
      it "should return new filename for css for all browsers except IE" do
        file = "/abc/googligoo/mycss.css"
        CssGenerator.new_filename(file, "mycss.css").should == file
      end
    end

    describe "#new_filename_for_ie" do
      it "should return new filename for css for IE" do
        file = "/dsaf/fe/2.css"
        CssGenerator.new_filename_for_ie(file, "ie.2.css").should == "/dsaf/fe/ie.2.css"
      end
    end

    describe "#encode_images" do
      it "should create two files" do
        original = File.join(File.dirname(__FILE__), "/../../public/sample.css")
        new_file = File.join(File.dirname(__FILE__), "/../../public/new_sample.css")
        new_file_for_ie = File.join(File.dirname(__FILE__), "../../public/ie.sample.css")
        CssGenerator.encode_images(original,"domen.com", 'new_sample.css', 'ie.sample.css', 20, false)
        File.exist?(new_file).should be_true
        File.exist?(new_file_for_ie).should be_true
      end
    end

    describe "#construct_mhtml_link" do
      it "should create link without public folder" do
        domen = "domen.com"
        CssGenerator.construct_mhtml_link(File.join(File.dirname(__FILE__), "../../public/temp.css"), domen).should == "http://domen.com/temp.css"
      end
    end
  end
end

