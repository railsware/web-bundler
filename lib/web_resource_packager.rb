$:.unshift File.dirname(__FILE__)
require 'web_resource_packager/block_parser'
require 'web_resource_packager/block_data'
require 'web_resource_packager/file_packager'
require 'web_resource_packager/settings'
require 'web_resource_packager/image_to_css.rb'
require 'singleton'
module WebResourcePackager
  class Bundler
    def initialize(settings = WebResourcePackager::Settings.new)
      @settings = settings 
      @packager = WebResourcePackager::FilePackager.new @settings
    end

    def set_settings(hash)
      @settings.set(hash)
    end

    def process(block)
      block_data = WebResourcePackager::BlockParser.parse(block)
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
        ImageToCss::CssFileGenerator.generate(file_path, @settings.domen, resource.bundle_filename(@settings), resource.ie_bundle_filename(@settings), @settings.max_image_size, ie_only)
      end
      block_data.child_blocks.each do |block|
        bundle_block_with_childs(block)
      end
    end
  end
end
