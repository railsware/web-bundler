$:.unshift File.dirname(__FILE__)
require 'image_encode_filter/image_data'
require 'image_encode_filter/css_generator'
module WebResourceBundler::Filters::ImageEncodeFilter
  class Filter < WebResourceBundler::Filters::BaseFilter
    FILE_PREFIX = 'base64_'
    IE_FILE_PREFIX = 'base64_ie_'
    MHTML_FILE_PREFIX = 'mhtml_'
    def initialize(settings, file_manager)
      super settings, file_manager
      @generator = CssGenerator.new(@settings, @file_manager)
    end

    def set_settings(settings)
      super settings
      @generator.set_settings(settings)
    end

    def apply!(block_data)
      added_files = [] 
      block_data.styles.each do |file|
        #creating new css file with content for IE
        ie_css_file = WebResourceBundler::ResourceFile.new_ie_css_file(encoded_filepath_for_ie(file.path), file.content.dup)
        #creating new mhtml file with images encoded in base64
        mhtml_file = WebResourceBundler::ResourceFile.new_mhtml_file(mhtml_filepath(file.path), "")
        file.path = encoded_filepath(file.path)
        #we've created separate file for IE so current file should be marked as CSS only
        file.types = [WebResourceBundler::ResourceFileType::CSS]
        unless file.content.empty?
          @generator.encode_images!(file.content)
          #getting images to construct mhtml file
          images = @generator.encode_images_for_ie!(ie_css_file.content, mhtml_file.path)
          mhtml_file.content = @generator.construct_mhtml_content(images)
        end
        added_files << ie_css_file
        added_files << mhtml_file
      end
      block_data.files += added_files 
      block_data
    end
    
    #path of a new file with images encoded
    def encoded_filepath(base_file_path)
      File.join(@settings[:cache_dir], FILE_PREFIX + File.basename(base_file_path))
    end

    #path of a new file for IE with images encoded
    def encoded_filepath_for_ie(base_file_path)
      File.join(@settings[:cache_dir], IE_FILE_PREFIX + File.basename(base_file_path))
    end

    #filepath of mhtml file for IE
    def mhtml_filepath(base_file_path)
      File.join(@settings[:cache_dir], MHTML_FILE_PREFIX + File.basename(base_file_path, ".*") + '.mhtml') 
    end

  end
end
