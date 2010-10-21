require File.absolute_path(File.join(File.dirname(__FILE__), "../spec_helper"))
module WebResourceBundler
  describe Settings do
    
    before(:each) do
      @s = Settings.new(@settings_hash)
    end

    it "should contain proper defaults after initialization" do
      @settings_hash.each_key do |k|
        @s[k].should == @settings_hash[k] 
        @s.send(k).should == @settings_hash[k]
      end
    end

    it "should set proper values using unexistent setters" do
      @s.domen = "new_domen"
      @s[:domen].should == "new_domen"
    end

    it "returns values while calling keys as methods" do
      @settings_hash.each_key do |k|
        @s.send(k).should == @settings_hash[k]
      end
    end

    it "returns nil on unexistent key" do
      @s.send("unexistent_key".to_sym).should be_nil
      @s["unexistent_key".to_sym].should be_nil
    end

    describe "#set" do
      it "merges current settings with passed hash" do
        @settings_hash[:domen] = "new_value"
        @s.set({:domen => "new_value"})
        @settings_hash.each do |k, v|
          @s.send(k).should == v 
        end
      end
    end

  end
end
