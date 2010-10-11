$:.unshift File.dirname(__FILE__)
require 'web_resource_packager/block_parser'
require 'web_resource_packager/block_data'
require 'web_resource_packager/file_packager'
require 'web_resource_packager/settings'
require 'web_resource_packager/image_to_css.rb'
require 'singleton'
module WebResourcePackager
  class Bundler
    include Singleton
    def initialize
      @settings = WebResourcePackager::Settings.new
      @packager = WebResourcePackager::FilePackager.new @settings
    end

    def set_settings(hash)
      @settings.set(hash)
    end

    def process(block)
      block_data = WebResourcePackager::BlockParser.parse(block)
      @packager.bundle_block(block_data)
    end
  end
end
