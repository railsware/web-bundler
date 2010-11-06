module WebResourceBundler
  module Filters
    module ImageEncodeFilter
      class CssGenerator
        TAGS = ['background-image', 'background']
        SEPARATOR = 'A_SEPARATOR'
        PATTERN = /(#{TAGS.join('|')})\s*:\s*url\(\s*['|"]([^\)]*)['|"]\s*\)/
        FILE_PREFIX = 'base64_'
        IE_FILE_PREFIX = 'base64_ie_'

        #creates cache dir if it doesn't exist
        def initialize(settings, file_manager)
          @settings = settings
          @file_manager = file_manager 
          @file_manager.create_cache_dir
        end

        #get image url from string that matches tag
        def get_value(str)
          match = PATTERN.match(str)
          if match
            return match[2]
          else
            return nil
          end		
        end
    
        #construct head of css file with definition of image data in base64
        def construct_header_for_ie(images)
          result = ""
          unless images.empty?
            result += "/*" + "\n"
            result += 'Content-Type: multipart/related; boundary="' + SEPARATOR + '"' + "\n"
            images.each_key do |key|
              result += images[key].construct_mhtml_image_data(SEPARATOR)
            end
            result += "*/" + "\n"
          end
          result
        end

        def construct_mhtml_link(filename)
          "http://#{File.join(@settings.domain, @settings.cache_dir, filename)}"
        end

        #name of a new file with images encoded
        def encoded_filename(base_file_path)
          FILE_PREFIX + File.basename(base_file_path)
        end

        #name of a new file for IE with images encoded
        def encoded_filename_for_ie(base_file_path)
          IE_FILE_PREFIX + File.basename(base_file_path)
        end
        
        #iterates through all tags found in css
        #if image exist and has proper size - it should be encoded
        #each tag with this kind of an image is replaced with new one (mhtml link for IE and base64 code for another browser
        #returns images hash - in case generator can build proper IE css header with base64 images encoded
        def encode_images_basic(content)
          images = {}
          new_content = content.gsub(PATTERN) do |s|
            data = ImageData.new(get_value(s), @settings.resource_dir) 
            if data.exist and data.size <= @settings.max_image_size and block_given?
              #using image url as key to prevent one image be encoded many times
              images[data.url] = data unless images[data.path]
              s.sub!(PATTERN, yield(data))
            else
              #if current image not found (html coder failed with url) we just leave this tag alone
              s.sub!(PATTERN, s)
            end
          end
          {:images => images, :content => new_content}
        end

        #generates css file for IE with encoded images using mhtml in cache dir
        def encode_images_for_ie(path, content)
          new_filename = encoded_filename_for_ie(path)
          result = encode_images_basic(content) do |image_data|
            "*#{TAGS[0]}: url(mhtml:#{construct_mhtml_link(new_filename)}!#{image_data.id})"
          end
          unless result[:images].empty?
            { File.join(@settings.cache_dir, new_filename) => (construct_header_for_ie(result[:images]) + result[:content]) }
          else
            { path => content }
          end
        end
    
        #generates css file with encoded images in cache dir 
        def encode_images(path, content)
          new_filename = encoded_filename(path)
          result = encode_images_basic(content) do |image_data|
              "#{TAGS[0]}:url('data:image/#{image_data.extension};base64,#{image_data.encoded}')"
          end
          unless result[:images].empty?
            { File.join(@settings.cache_dir, new_filename) => result[:content] }
          else
            { path => content }
          end
        end

      end
    end
  end
end
