module WebResourceBundler
  module Filters
    module ImageEncodeFilter
      class CssGenerator
        TAGS = ['background-image', 'background']
        SEPARATOR = 'A_SEPARATOR'
        PATTERN = /((#{TAGS.join('|')})\s*:[^\(]*)url\(\s*['|"]([^\)]*)['|"]\s*\)/

        def initialize(settings, file_manager)
          @settings = settings
          @file_manager = file_manager 
        end

        def set_settings(settings)
          @settings = settings
          @settings[:max_image_size] = 20 unless @settings[:max_image_size]
        end

        #construct mhtml head of css file with definition of image data in base64
        def construct_mhtml_content(images)
          result = ""
          unless images.empty?
            result << 'Content-Type: multipart/related; boundary="' << SEPARATOR << '"' << "\n\n"
            #each image found in css should be defined in header with base64 encoded content
            images.each_key do |key|
              result << images[key].construct_mhtml_image_data('--' + SEPARATOR)
            end
            result << "\n" << '--' << SEPARATOR << '--' << "\n"
          end
          result
        end

        #creates mhtml link to use in css tags instead of image url
        def construct_mhtml_link(filepath)
          "#{@settings[:protocol]}://#{File.join(@settings[:domain], filepath)}"
        end
        
        #iterates through all tags found in css
        #if image exist and has proper size - it should be encoded
        #each tag with this kind of an image is replaced with new one (mhtml link for IE and base64 code for another browser
        #returns images hash - in case generator can build proper IE css header with base64 images encoded
        def encode_images_basic!(content)
          images = {}
          new_content = content.gsub!(PATTERN) do |s|
            tag, url = $1, $3
            #this constructor will write in log if image doesn't exist
            data = ImageData.new(url, @settings[:resource_dir]) 
            if !url.empty? and data.exist and data.size <= @settings[:max_image_size] and block_given?
              #using image url as key to prevent one image be encoded many times
              images[data.url] = data unless images[data.path]
              #changing string using provided block
              s = yield(data, tag) if block_given?
            else
              #returning the same string because user failed with image path - such image non existent
              s
            end
          end
          images
        end

        #generates css file for IE with encoded images using mhtml in cache dir
        #mhtml_filepath - path to file with images encoded in base64
        def encode_images_for_ie!(content, mhtml_filepath)
          #creating new css content with images encoded in base64
          images = encode_images_basic!(content) do |image_data, tag|
            "*#{tag}url(mhtml:#{construct_mhtml_link(mhtml_filepath)}!#{image_data.id})"
          end
          images
        end
    
        #generates css file with encoded images in cache dir 
        def encode_images!(content)
          #encoding images in content
          images = encode_images_basic!(content) do |image_data, tag|
              "#{tag}url('data:image/#{image_data.extension};base64,#{image_data.encoded}')"
          end
          images
        end

      end
    end
  end
end
