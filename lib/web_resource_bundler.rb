$:.unshift File.join(File.dirname(__FILE__), 'web_resource_bundler')
require 'block_parser'
require 'block_data'
require 'settings'
require 'resource_bundle'
require 'bundle_filter'
require 'file_manager'
require 'image_encode_filter'
require 'singleton'
module WebResourceBundler
  class Bundler
    def initialize(settings = Settings.new)
      @settings = settings 
    end

    def set_settings(hash)
      @settings.set(hash)
    end

    def process(block)
      block_data = BlockParser.parse(block)
      filters = []
      filters << BundleFilter::Filter.new(@settings)
      block_data.apply_filters(filters)

      #processing block files with cdn filters
      
      #construct_output_block(block_data)
    end

  end
end
