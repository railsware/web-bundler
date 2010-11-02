$:.unshift File.join(File.dirname(__FILE__), 'web_resource_bundler')
require 'content_management/block_parser'
require 'content_management/block_data'
require 'content_management/css_url_rewriter'
require 'content_management/resource_bundle'
require 'content_management/block_constructor'

require 'settings'
require 'file_manager'
require 'singleton'
require 'logger'
require 'filters'

module WebResourceBundler
  class Bundler
    def initialize(settings = {})
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
      filters << Filters::BundleFilter::Filter.new(@settings, @logger)
      block_data.apply_filters(filters)

      return BlockConstructor.construct_block(block_data)
      #processing block files with cdn filters
      
    end

  end
end
