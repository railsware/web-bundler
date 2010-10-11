require File.join(File.dirname(__FILE__), "../../spec_helper")
module WebResourcePackager
  describe ResourceBundle::Data do
    before(:each) do
      @resource = ResourceBundle::Data.new(ResourceBundle::CSS, @@styles) 
      @filename = ResourceBundle::CSS[:name] + '_' + @resource.get_md5(@@settings) + '.' + @@settings.language + '.' + ResourceBundle::CSS[:ext] 
    end

    describe "#get_md5" do
      it "returns md5 from filenames and else additional data" do
        items = [@@styles, @@settings.domen, @@settings.protocol]
        @resource.get_md5(@@settings).should == Digest::MD5.hexdigest(items.flatten.join('|'))
      end
    end

    describe "#bundle_filename" do
      it "returns filename of bundle constructed from passed files" do
        @resource.bundle_filename(@@settings).should == @filename 
      end
    end

    describe "#add_filenames" do
      it "adds filenames to data files" do
        @resource.add_filenames ['new-file.css']
        @resource.files.include?('new-file.css').should be_true
      end
    end


  end
end
