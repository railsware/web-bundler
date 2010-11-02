$:.unshift File.dirname(__FILE__)
require 'image_encode_filter/image_data'
require 'base64'
require 'image_encode_filter/css_generator'
module WebResourceBundler
  module Filters
    module ImageEncodeFilter
      class Filter < WebResourceBundler::Filters::BaseFilter

        def initialize(settings, logger)
          super settings, logger
          @generator = CssGenerator.new settings
        end

        def apply(block_data)
          super do
            @result_files = []
            resource = block_data.css
            resource.files.each do |file|
              @result_files << @generator.encode_images_for_ie(file)
              if block_data.condition.empty?
                @result_files << @generator.encode_images(file)
              end
            end
            block_data.css.files = @result_files
          end
        end

        def cleanup
          file_manager = FileManager.new @settings
          @result_files.each do |file|
            File.delete(file_manager.full_path(file))
          end
        end
      end
    end
  end
end
