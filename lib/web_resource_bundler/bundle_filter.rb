$:.unshift File.join(File.dirname(__FILE__), "/bundle_filter")
require 'resource_packager'
require 'css_url_rewriter'
module WebResourceBundler::BundleFilter
  class Filter

    def initialize(settings)
      @packager = ResourcePackager.new settings
    end

    def apply(block_data)
      result_files = []
      result_files << @packager.bundle_resource(block_data.css)
      result_files << @packager.bundle_resource(block_data.js)
      #marking block data as bundled to tell subsequent filters what files to operate
      block_data.bundled = true
      block_data.result_files = result_files
    end

  end
end
