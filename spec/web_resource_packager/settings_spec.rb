require File.join(File.dirname(__FILE__), "../spec_helper")
module WebResourcePackager
  describe Settings do
    
    before(:each) do
      @s = Settings.new(@@settings_hash)
    end

    it "should contain proper defaults after initialization" do
      @@settings_hash.each_key do |k|
        @s[k].should == @@settings_hash[k] 
        @s.send(k).should == @@settings_hash[k]
      end
    end

  end
end

