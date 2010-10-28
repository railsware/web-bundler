$:.unshift File.join(File.dirname(__FILE__), "/bundle_filter")
require 'resource_packager'
require 'content_managment/css_url_rewriter'
require 'filter_base'
module WebResourceBundler::BundleFilter
  class Filter < WebResourceBundler::FilterBase

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
      File.delete(File.join(@settings.resouce_dir, @css_bundle))
      File.delete(File.join(@settings.resouce_dir, @js_bundle))
    end

  end
end
