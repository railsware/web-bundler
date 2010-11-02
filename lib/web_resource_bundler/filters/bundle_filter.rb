$:.unshift File.join(File.dirname(__FILE__), "/bundle_filter")
require 'bundle_filter/resource_packager'
require 'base_filter'
module WebResourceBundler
  module Filters
    module BundleFilter
      class Filter < WebResourceBundler::Filters::BaseFilter

        def initialize(settings, logger)
          super(settings, logger)
          @packager = ResourcePackager.new settings
        end

        def apply(block_data)
          super do
            @css_bundle = @packager.bundle_resource(block_data.css) unless block_data.css.files.empty?
            @js_bundle = @packager.bundle_resource(block_data.js) unless block_data.js.files.empty?
            block_data.css.files = [@css_bundle]
            block_data.js.files = [@js_bundle]
          end
        end

        def cleanup
          file_manager = FileManager.new(@settings)
          File.delete(file_manager.full_path(@css_bundle)) if @css_bundle and File.exist?(file_manager.full_path(@css_bundle))
          File.delete(file_manager.full_path(@js_bundle)) if @js_bundle and File.exist?(file_manager.full_path(@js_bundle))
        end

      end
    end
  end
end
