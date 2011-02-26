$:.unshift File.dirname(__FILE__)
require 'image_encode_filter/image_data'
require 'image_encode_filter/css_generator'
module WebResourceBundler::Filters::ImageEncodeFilter
  class Filter < WebResourceBundler::Filters::BaseFilter

    FILE_PREFIX       = 'base64_'
    IE_FILE_PREFIX    = 'base64_ie_'
    MHTML_FILE_PREFIX = 'mhtml_'

    def initialize(settings, file_manager)
      super settings, file_manager
      @generator = CssGenerator.new(@settings, @file_manager)
    end

    def set_settings(settings)
      super settings
      @generator.set_settings(settings)
    end

    #creates one new css file with mhtml content for IE < 8
    #original css file content changed with images encoded in it in base64
    #also its type changed to CSS because from this point it is valid only for
    #normal browsers and IE > 7
    def apply!(block_data)
      new_files = []
      block_data.styles.each do |file|
        base_name = file.path
        mhtml_css_file = create_mhtml_css_file(file) 
        mhtml_file     = create_mhtml_file(file)
        change_css_file!(file)
        unless file.content.empty?
          encode_images_in_css_file!(file)
          images = change_images_to_mhtml_links!(mhtml_css_file, mhtml_filepath(base_name))
          mhtml_file.content = @generator.construct_mhtml_content(images.values)
        end
        block_data.files << mhtml_css_file
        block_data.files << mhtml_file
      end
      block_data
    end

    private

    def encode_images_in_css_file!(file)
      @generator.encode_images!(file.content)
    end

    def change_images_to_mhtml_links!(file, mhtml_path)
      @generator.encode_images_for_ie!(file.content, mhtml_path)
    end

    def change_css_file!(file)
      file.path = css_filepath(file.path)
      file.type = WebResourceBundler::ResourceFileType::BASE64_CSS
    end

    def create_mhtml_css_file(css_file)
      WebResourceBundler::ResourceFile.new_mhtml_css_file(mhtml_css_filepath(css_file.path), css_file.content.dup)
    end

    def create_mhtml_file(css_file)
      WebResourceBundler::ResourceFile.new_mhtml_file(mhtml_filepath(css_file.path))
    end
    
    #path to new file with images encoded in base64 for normal browsers
    def css_filepath(base_file_path)
      File.join(@settings[:cache_dir], FILE_PREFIX + File.basename(base_file_path))
    end

    #path to new file for IE with images encoded in it
    def mhtml_css_filepath(base_file_path)
      File.join(@settings[:cache_dir], IE_FILE_PREFIX + File.basename(base_file_path))
    end

		#path to file with mhtml content for IE
    def mhtml_filepath(base_file_path)
      File.join(@settings[:cache_dir], MHTML_FILE_PREFIX + File.basename(base_file_path, '.css') + '.mhtml')
    end

  end
end
