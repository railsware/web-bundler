require 'yaml'

module WebResourceBundler

  module SettingsReader

    extend self

    DEFAULT_SETTINGS_PATH = 'config/web_resource_bundler.yml'

    #if no settings found - returning empty hash
    def read_from_file(rails_root, rails_env)
      settings = {}
      file_path = settings_file_path(rails_root)
      if File.exist?(file_path)
        all_settings = YAML::load(File.open(file_path))
        if all_settings[rails_env]
          settings = to_options(all_settings[rails_env])
        end
      end
      settings
    end

    def to_options(data)
      data.each_with_object({}) do |(key, value), options|
        value = to_options(value) if value.is_a?(Hash)
        options[(key.to_sym rescue key) || key] = value
      end
    end

    private

    #returns path of config file
    def settings_file_path(rails_root)
      File.join(rails_root, DEFAULT_SETTINGS_PATH)
    end

  end

  class Settings

    DEFAULT_RESOURCE_DIR  = 'public'
    DEFAULT_CACHE_DIR     = 'cache'
    OBLIGATORY_SETTINGS   = [:resource_dir, :cache_dir]

    class << self

      attr_accessor :settings

      #creates settings from config file
      #and merging them with defaults
      def create_settings(rails_root, rails_env)
        config = SettingsReader.read_from_file(rails_root, rails_env)
        @settings = defaults(rails_root).merge(config)
        @settings[:resource_dir] = File.join(rails_root, DEFAULT_RESOURCE_DIR)
        @settings
      end

      #ensures that settings has obligatory keys present
      def correct?(settings = @settings)
        OBLIGATORY_SETTINGS.each { |key| return false unless settings.has_key?(key) }
        true
      end

      #returns setting for particular filter, merged with common settings
      def filter_settings(filter_name)
        commons(@settings).merge(@settings[filter_name])
      end

      #setting request specific settings like domain and protocol
      def set_request_specific_data!(settings, domain, protocol)
        settings[:domain]   = domain
        settings[:protocol] = protocol
        settings
      end

      #sets new settings by merging with existing
      def set(settings)
        @settings.merge!(settings)
      end

      def filter_used?(name)
        @settings[name] && @settings[name][:use]
      end

      protected

      #creates defaults settings
      def defaults(rails_root)
        {
          :resource_dir    => File.join(rails_root, DEFAULT_RESOURCE_DIR),
          :cache_dir       => DEFAULT_CACHE_DIR,
          :bundle_filter   => {
            :use => true
          },
          :cdn_filter      => {
            :use => false
          },
          :base64_filter   => {
            :use            => true,
            :max_image_size => 20
          },
          :compress_filter => {
            :use          => false,
            :obfuscate_js => true
          }
        }
      end

      #settings common for all filters
      def commons(settings)
        {
          :resource_dir => settings[:resource_dir],
          :cache_dir    => settings[:cache_dir]
        }
      end

    end

  end
end
