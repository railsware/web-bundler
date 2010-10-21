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
      resource.files.each do |file|
        result_files << @generator.encode_images_for_ie(file)
        if block_data.condition.empty?
          result_files << @generator.encode_images(file)
        end
      end
      block_data.css.files = result_files
    end


  end
end
