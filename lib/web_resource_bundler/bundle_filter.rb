$:.unshift File.join(File.dirname(__FILE__), "/bundle_filter")
require 'resource_packager'
require 'css_url_rewriter'
module WebResourceBundler::BundleFilter
  class Filter

    def initialize(settings)
      @packager = ResourcePackager.new settings
    end

    def apply(block_data)
      block_data.css.files = [@packager.bundle_resource(block_data.css)]
      block_data.js.files = [@packager.bundle_resource(block_data.js)]
    end

  end
end
