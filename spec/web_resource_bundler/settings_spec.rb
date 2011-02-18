require File.expand_path(File.join(File.dirname(__FILE__), "../spec_helper"))
describe WebResourceBundler::Settings do

  before(:each) do
    @s = settings
    Settings.set(@s)
  end

  describe "#defaults" do
    it "returns default required settings for bundler" do
      root = '/root' 
      settings = Settings.send(:defaults, root)
      settings[:resource_dir].should == File.join(root, Settings::DEFAULT_RESOURCE_DIR)
      settings[:log_path].should == File.join(root, Settings::DEFAULT_LOG_PATH)
      settings[:cache_dir].should == Settings::DEFAULT_CACHE_DIR
      settings[:bundle_filter][:use].should == true
      settings[:cdn_filter][:use].should == false
      settings[:base64_filter][:use].should == true
    end
  end

  describe "#commons" do
    it "returns settings common to all filters" do
      settings = Settings.send(:commons, @s)
      settings.keys.size.should == 2
      settings[:resource_dir].should == @s[:resource_dir]
      settings[:cache_dir].should == @s[:cache_dir]
    end
  end

  describe "#read_from_file" do
    it "loads settings from yaml file" do
      rails_root = root_dir 
      content = File.read(File.join(root_dir, 'config/web_resource_bundler.yml'))
      rails_env = 'development'
      original = YAML::load(content)[rails_env]
      settings = Settings.send(:read_from_file, rails_root, rails_env) 
      original.each_key do |key|
        settings[key].should == original[key]
      end
      settings[:resource_dir].should == File.join(root_dir, Settings::DEFAULT_RESOURCE_DIR)
    end
    it "returns empty hash if file isn't exist" do
      Settings.send(:read_from_file, '', '').should == {}
    end
  end

  describe "#correct?" do
    it "should return true if all required keys present" do
      Settings.correct?.should be_true
    end
    it "returns false if one of the keys isn't present" do
      Settings.settings.delete(:resource_dir)
      Settings.correct?.should be_false
    end
  end

  describe "filter_settings" do
    it "returns filter settings merged with common settings" do
      cdn_sets = Settings.filter_settings(:cdn_filter)
      cdn_sets[:resource_dir].should == Settings.settings[:resource_dir]
      cdn_sets[:cache_dir].should == Settings.settings[:cache_dir]
    end
  end

  describe "#set_request_specific_data!" do
    it "sets domain and protocol for settings" do
      s = {}
      Settings.set_request_specific_data!(s, 'google.com', 'http')
      s[:domain].should == 'google.com'
      s[:protocol].should == 'http'
    end
  end

end

