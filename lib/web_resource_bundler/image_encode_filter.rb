$:.unshift File.dirname(__FILE__)
require 'image_encode_filter/image_data'
require 'base64'
require 'image_encode_filter/css_generator'
module WebResourceBundler::ImageEncodeFilter
  class Filter

    def initialize(settings)
      @settings = settings
      @generator = CssGenerator.new settings
    end

    def apply(block_data)
      result_files = []
      resource = block_data.css
      if block_data.bundled
        result_files<< @generator.encode_images_for_ie(File.join(@settings.cache_dir, resource.bundle_filename(@settings)))
        if block_data.condition.empty?
          result_files<< @generator.encode_images(File.join(@settings.cache_dir, resource.bundle_filename(@settings)))
        end
        result_files<< File.join(@settings.cache_dir, block_data.js.bundle_filename(@settings))
      else
        resource.files.each do |file|
          result_files << @generator.encode_images_for_ie(file)
          if block_data.condition.empty?
            result_files << @generator.encode_images(file)
          end
        end
        result_files += block_data.js.files
      end
      block_data.result_files = result_files
    end


  end
end
