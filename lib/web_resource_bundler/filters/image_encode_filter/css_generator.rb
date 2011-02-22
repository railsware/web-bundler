module WebResourceBundler
  module Filters
    module ImageEncodeFilter
      class CssGenerator

        TAGS               = ['background-image', 'background']
        SEPARATOR          = 'A_SEPARATOR'
        PATTERN            = /((#{TAGS.join('|')})\s*:[^\(]*)url\(\s*['|"]([^\)]*)['|"]\s*\)/
        MAX_IMAGE_SIZE     = 32 #IE 8 limitation
        MHTML_CONTENT_TYPE = 'Content-Type: multipart/related; boundary="'

        def initialize(settings, file_manager)
          @settings     = settings
          @file_manager = file_manager 
        end

        def set_settings(settings)
          @settings = settings
        end

        #construct mhtml head of css file with definition of image data in base64
        #each image found in css should be defined in header with base64 encoded content
        def construct_mhtml_content(images)
          result = "/*\n"
          if images.any?
            result << mhtml_header
            result << mhtml_images_data(images)
            result << mhtml_footer 
          end
          result << "*/\n"
        end

        #generates css file for IE with encoded images using mhtml in cache dir
        #mhtml_filepath - path to file with images encoded in base64
        #creating new css content with images encoded in base64
        def encode_images_for_ie!(content, path)
          encode_images_basic!(content) do |image_data, tag|
            "#{tag}url(mhtml:#{construct_mhtml_link(path)}!#{image_data.id})"
          end
        end
    
        #generates css file with encoded images in cache dir 
        def encode_images!(content)
          encode_images_basic!(content) do |image_data, tag|
            "#{tag}url('data:image/#{image_data.extension};base64,#{image_data.encoded}')"
          end
        end

        private

        def mhtml_header
          MHTML_CONTENT_TYPE + SEPARATOR + '"' + "\n\n"
        end

        def mhtml_footer
          "\n--" + SEPARATOR + "--\n"
        end

        def mhtml_images_data(images)
          images.map {|i| i.construct_mhtml_image_data('--' + SEPARATOR) }.join
        end

        #creates mhtml link to use in css tags instead of image url
        def construct_mhtml_link(filepath)
          "#{@settings[:protocol]}://#{File.join(@settings[:domain], filepath)}"
        end


        #iterates through all tags found in css
        #if image exist and has proper size - it should be encoded
        #each tag with this kind of an image is replaced with new one 
        #mhtml link for IE and base64 code for another browser
        #returns images hash - in case generator can build proper IE css header with base64 images encoded
        def encode_images_basic!(content)
          images = {}
          content.gsub!(PATTERN) do |s|
            tag, url = $1, $3
            data     = ImageData.new(url, @settings[:resource_dir])
            if !url.empty? && data.exist && data.size <= image_size_limit && block_given?
              images[url] = data unless images[url]
              yield(images[url], tag)
            else
              s
            end
          end
          images
        end

        def image_size_limit
          @settings[:max_image_size] ? [MAX_IMAGE_SIZE, @settings[:max_image_size]].min : MAX_IMAGE_SIZE
        end

      end
    end
  end
end
