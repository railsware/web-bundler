require 'yaml'
class WebResourceBundler::SettingsManager

  DEFAULT_LOG_PATH = 'log/web_resource_bundler.log'
  DEFAULT_RESOURCE_DIR = 'public'
  DEFAULT_SETTINGS_PATH = 'config/web_resource_bundler.yml'
  DEFAULT_CACHE_DIR = 'cache'

  class << self

    def create_settings(rails_root, rails_env)
      settings = {}
      if File.exist?(rails_root)
        #reading settings from file in config dir
        settings = settings_from_file(rails_root, rails_env) 
        #building required defaults
        defaults = create_default_settings(rails_root)
        #merging required with read from file settings
        #if there's no file settings will contain just required defaults
        settings = defaults.merge(settings)
      end
      settings
    end

    def create_default_settings(rails_root)
      settings = {}
      settings[:resource_dir] = File.join(rails_root, DEFAULT_RESOURCE_DIR)
      settings[:log_path] = File.join(rails_root, DEFAULT_LOG_PATH)
      settings[:cache_dir] = DEFAULT_CACHE_DIR
      settings[:bundle_filter] = {
        :use => true
      }
      settings[:cdn_filter] = {
        :use => false
      }
      settings[:base64_filter] = {
        :use => true,
        :max_image_size => 20
      }
      settings
    end

    def common_settings(settings)
      {
        :resource_dir => settings[:resource_dir],
        :cache_dir => settings[:cache_dir],
      }
    end

    def settings_from_file(rails_root, rails_env)
      settings = {} 
      settings_file_path = File.join(rails_root, DEFAULT_SETTINGS_PATH)
      if File.exist?(settings_file_path)
        settings_file = File.open(settings_file_path)
        all_settings = YAML::load(settings_file)
        if all_settings[rails_env]
          settings = all_settings[rails_env]
          settings[:resource_dir] = File.join(rails_root, DEFAULT_RESOURCE_DIR)
        end
      end
      settings
    end

    def settings_correct?(settings)
      %w{resource_dir log_path cache_dir}.each do |key|
        return false unless settings.has_key?(key.to_sym)
      end
      return true
    end

    %w{base64_filter cdn_filter bundle_filter}.each do |filter_name|
      define_method "#{filter_name}_settings" do |settings|
        self.common_settings(settings).merge(settings[filter_name.to_sym])
      end
    end 

    def set_request_specific_settings!(settings, domain, protocol)
      settings[:domain] = domain
      settings[:protocol] = protocol
      settings
    end
  end
end
