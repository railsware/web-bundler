$:.unshift File.join(File.dirname(__FILE__), 'web_resource_bundler')
require 'content_managment/block_parser'
require 'content_managment/block_data'
require 'settings'
require 'content_managment/resource_bundle'
require 'bundle_filter'
require 'file_manager'
require 'image_encode_filter'
require 'singleton'
require 'content_managment/block_constructor'
require 'cdn_filter'
require 'logger'
module WebResourceBundler
  class Bundler
    def initialize(settings = Settings.new)
      @settings = Settings.new settings
      file = File.open(@settings.log_path, File::WRONLY | File::APPEND | File::CREAT)
      @logger = Logger.new(file)
    end

    def set_settings(hash)
      @settings.set(hash)
    end

    def process(block)
      block_data = BlockParser.parse(block)
      filters = []
      filters << BundleFilter::Filter.new(@settings, @logger)
      block_data.apply_filters(filters)

      return BlockConstructor.construct_block(block_data)
      #processing block files with cdn filters
      
    end

  end
end
