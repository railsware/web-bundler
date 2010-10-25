$:.unshift File.join(File.dirname(__FILE__), 'web_resource_bundler')
require 'block_parser'
require 'block_data'
require 'settings'
require 'resource_bundle'
require 'bundle_filter'
require 'file_manager'
require 'image_encode_filter'
require 'singleton'
require 'block_constructor'
module WebResourceBundler
  class Bundler
    def initialize(settings = Settings.new)
      @settings = Settings.new settings 
    end

    def set_settings(hash)
      @settings.set(hash)
    end

    def process(block)
      block_data = BlockParser.parse(block)
      filters = []
      filters << BundleFilter::Filter.new(@settings)
      block_data.apply_filters(filters)

      return BlockConstructor.construct_block(block_data)
      #processing block files with cdn filters
      
    end

  end
end
