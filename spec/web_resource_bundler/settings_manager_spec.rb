require File.expand_path(File.join(File.dirname(__FILE__), "../spec_helper"))
describe WebResourceBundler::SettingsManager do

  before(:each) do
    @s = settings
  end

  describe "#create_default_settings" do
    it "returns default required settings for bundler" do
      root = '/root' 
      settings = SettingsManager.create_default_settings(root)
      settings[:resource_dir].should == File.join(root, SettingsManager::DEFAULT_RESOURCE_DIR)
      settings[:log_path].should == File.join(root, SettingsManager::DEFAULT_LOG_PATH)
      settings[:cache_dir].should == SettingsManager::DEFAULT_CACHE_DIR
      settings[:bundle_filter][:use].should == true
      settings[:cdn_filter][:use].should == false
      settings[:base64_filter][:use].should == true
    end
  end

  describe "#common_settings" do
    it "returns settings common to all filters" do
      settings = SettingsManager.common_settings(@s)
      settings.keys.size.should == 2
      settings[:resource_dir].should == @s[:resource_dir]
      settings[:cache_dir].should == @s[:cache_dir]
    end
  end

  describe "#settings_from_file" do
    it "loads settings from yaml file" do
      rails_root = root_dir 
      content = File.read(File.join(root_dir, 'config/web_resource_bundler.yml'))
      rails_env = 'development'
      original = YAML::load(content)[rails_env]
      settings = SettingsManager.settings_from_file(rails_root, rails_env) 
      original.each_key do |key|
        settings[key].should == original[key]
      end
      settings[:resource_dir].should == File.join(root_dir, SettingsManager::DEFAULT_RESOURCE_DIR)
    end
    it "returns empty hash if file isn't exist" do
      SettingsManager.settings_from_file('', '').should == {}
    end
  end

  describe "#settings_correct?" do
    it "should return true if all required keys present" do
      SettingsManager.settings_correct?(@s).should be_true
    end
    it "returns false if one of the keys isn't present" do
      @s.delete(:resource_dir)
      SettingsManager.settings_correct?(@s).should be_false
    end
  end

  context "dynamically created filter settings methods" do
    it "properly creates methods for each filter settings" do
      %w{cdn_filter_settings base64_filter_settings bundle_filter_settings}.each do |method|
        if RUBY_VERSION > '1.9.0'
          key = method.to_sym 
        else
          key = method
        end
        SettingsManager.public_methods.include?(key).should be_true
      end
    end
    describe "#cdn_filter_settings" do
      it "returns cdn settings merged with commons" do
        cdn = SettingsManager.cdn_filter_settings(@s)
        cdn[:resource_dir].should == @s[:resource_dir]
        cdn[:cache_dir].should == @s[:cache_dir]
        cdn[:use].should == @s[:cdn_filter][:use]
      end
    end
  end

  describe "#set_request_specific_settings!" do
    it "sets domain and protocol for settings" do
      s = {}
      SettingsManager.set_request_specific_settings!(s, 'google.com', 'http')
      s[:domain].should == 'google.com'
      s[:protocol].should == 'http'
    end
  end

end

