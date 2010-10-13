$:.unshift File.dirname(__FILE__)
require 'web_resource_bundler/block_parser'
require 'web_resource_bundler/block_data'
require 'web_resource_bundler/resource_packager'
require 'web_resource_bundler/settings'
require 'web_resource_bundler/image_encode_filter'
require 'singleton'
module WebResourceBundler
  class Bundler
    def initialize(settings = Settings.new)
      @settings = settings 
      @packager = ResourcePackager.new @settings
    end

    def set_settings(hash)
      @settings.set(hash)
    end

    def process(block)
      block_data = BlockParser.parse(block)
      bundle_block_with_childs(block_data)

      #processing block files with cdn filters
      
      #construct_output_block(block_data)
    end

    def bundle_block_with_childs(block_data)
      @packager.bundle_resource(block_data.css)
      @packager.bundle_resource(block_data.js)
      if @settings.encode_images
        resource = block_data.css
        file_path = @packager.bundle_file_path(resource.bundle_filename(@settings))
        ie_only = block_data.condition.empty? ? true : false
        ImageEncodeFilter::CssGenerator.encode_images(file_path, @settings.domen, resource.bundle_filename(@settings), resource.ie_bundle_filename(@settings), @settings.max_image_size, ie_only)
      end
      block_data.child_blocks.each do |block|
        bundle_block_with_childs(block)
      end
    end
  end
end
