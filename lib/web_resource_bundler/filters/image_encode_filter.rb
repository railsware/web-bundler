$:.unshift File.dirname(__FILE__)
require 'image_encode_filter/image_data'
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

    def apply!(block_data)
      mhtml_files = [] 
      block_data.styles.each do |file|
        new_mhtml_file = WebResourceBundler::ResourceFile.new_mhtml_file(file.path.dup, file.content.dup)
        unless file.content.empty?
          @generator.encode_images!(file)
          @generator.encode_images_for_ie!(new_mhtml_file)
        else
          new_mhtml_file.path = @generator.encoded_filepath_for_ie(new_mhtml_file.path)
          file.path = @generator.encoded_filepath(file.path)
        end
        mhtml_files << new_mhtml_file
      end
      block_data.files += mhtml_files 
      block_data
    end

  end
end
