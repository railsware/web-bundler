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

    def set_settings(settings)
      super settings
      @generator.set_settings(settings)
    end

    def apply(block_data)
      result_files = {} 
      ie_result_files = {}
      resource = block_data.css
      resource.files.each_pair do |path, content|
        @generator.encode_images_for_ie(path, content)
        ie_result_files.merge!(@generator.encode_images_for_ie(path, content))
        if block_data.condition.empty?
          result_files.merge!(@generator.encode_images(path, content))
        end
      end
      if block_data.condition.empty? and ie_result_files.size > 0
        ie_block_data = WebResourceBundler::BlockData.new("[if IE]")
        ie_block_data.css.files = ie_result_files
        block_data.child_blocks << ie_block_data
      else
        result_files.merge!(ie_result_files)
      end
      block_data.css.files = result_files
    end

    def change_resulted_files!(block_data)
      result_files = {} 
      ie_result_files = {}
      block_data.css.files.keys.each do |path|
        ie_result_files[@generator.encoded_filename_for_ie(path)] = ""
        if block_data.condition.empty?
          result_files[@generator.encoded_filename(path)] = ""
        end
      end
      if block_data.condition.empty? and ie_result_files.size > 0
        ie_block_data = WebResourceBundler::BlockData.new("[if IE]")
        ie_block_data.css.files = ie_result_files
        block_data.child_blocks << ie_block_data
      else
        result_files.merge!(ie_result_files)
      end
      block_data.css.files = result_files
    end

  end
end
