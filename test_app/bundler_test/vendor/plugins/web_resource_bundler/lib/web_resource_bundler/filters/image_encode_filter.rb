$:.unshift File.dirname(__FILE__)
require 'image_encode_filter/image_data'
require 'base64'
require 'image_encode_filter/css_generator'
module WebResourceBundler::Filters::ImageEncodeFilter
  class Filter < WebResourceBundler::Filters::BaseFilter

    def initialize(settings, file_manager)
      super settings, file_manager
      @generator = CssGenerator.new(@settings, @file_manager)
    end

    def apply(block_data)
      result_files = {} 
      resource = block_data.css
      resource.files.each_pair do |path, content|
        WebResourceBundler::CssUrlRewriter.rewrite_content_urls!(path, content)
        @generator.encode_images_for_ie(path, content)
        result_files.merge!(@generator.encode_images_for_ie(path, content))
        if block_data.condition.empty?
          result_files.merge!(@generator.encode_images(path, content))
        end
      end
      block_data.css.files = result_files
    end

    def change_resulted_files!(block_data)
      result_files = {} 
      block_data.css.files.keys.each do |path|
        result_files[@generator.encoded_filename_for_ie(path)] = ""
        if block_data.condition.empty?
          result_files[@generator.encoded_filename(path)] = ""
        end
      end
      block_data.css.files = result_files
    end

  end
end
