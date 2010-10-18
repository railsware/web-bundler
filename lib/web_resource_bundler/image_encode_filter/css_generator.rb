module WebResourceBundler::ImageEncodeFilter
  class CssGenerator
    TAGS = ['background-image', 'background']
    SEPARATOR = 'A_SEPARATOR'
    PATTERN = /(#{TAGS.join('|')})\s*:\s*url\(\s*['|"]([^;]*)['|"]\s*\)\s*;/
    FILE_PREFIX = 'base64_'
    IE_FILE_PREFIX = 'base64_ie_'

    #creates cache dir if it doesn't exist
    def initialize(settings)
      @settings = settings
      path = File.join(@settings.resource_dir, @settings.cache_dir)
      unless Dir.exist?(path)
        Dir.mkdir(path)
      end
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
    
    #checks if file exists and has css extension, if so - reads whole file in string
    def read_css_file(file)
      path = File.join(@settings.resource_dir, file)
      if File.exist?(path) and File.extname(path) == ".css"
        File.read(path) 
      else
        nil
      end
    end

    #iterates through all tags found in css
    #if image exist and has proper size - it should be encoded
    #each tag with this kind of an image is replaced with new one (mhtml link for IE and base64 code for another browser
    #returns images hash - in case generator can build proper IE css header with base64 images encoded
    def encode_images_basic(content)
      images = {}
      content.gsub!(PATTERN) do |s|
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
      images
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
      "http://#{File.join(@settings.domen, @settings.cache_dir, filename)}"
    end

    def write_css_file(filename, file_content)
      begin
        path = File.join(@settings.resource_dir, @settings.cache_dir, filename)
        File.open(path, "w") do |file|
          file.write file_content
        end
        return true
      rescue
        return false
      end
    end
    
    #name of a new file with images encoded
    def encoded_filename(filename)
      FILE_PREFIX + filename
    end

    #name of a new file for IE with images encoded
    def encoded_filename_for_ie(filename)
      IE_FILE_PREFIX + filename
    end

    #generates css file for IE with encoded images using mhtml in cache dir
    def encode_images_for_ie(file)
      if css_file = read_css_file(file)
        new_filename = encoded_filename_for_ie(File.basename(file))
        images = encode_images_basic(css_file) do |image_data|
          "*#{TAGS[0]}: url(mhtml:#{construct_mhtml_link(new_filename)}!#{image_data.id});"
        end
        #if images that could be encoded found in file than new base64 file should be created
        done = write_css_file(new_filename, construct_header_for_ie(images) + css_file) unless images.empty?
      end
      #if base64 file was created than returning new file path in resource dir, if wasn't - returnig that path of original file
      done ? File.join(@settings.cache_dir, new_filename) : file
    end
    
    #generates css file with encoded images in cache dir 
    def encode_images(file)
      if css_file = read_css_file(file)
        new_filename = encoded_filename(File.basename(file))
        images = encode_images_basic(css_file) do |image_data|
            "#{TAGS[0]}:url('data:image/#{image_data.extension};base64,#{image_data.encoded}');"
        end
        #if images that could be encoded found in file than new base64 file should be created
        done = write_css_file(new_filename, css_file) unless images.empty?
      end
      #if base64 file was created than returning new file path in resource dir, if wasn't - returnig that path of original file
      done ? File.join(@settings.cache_dir, new_filename) : file
    end

  end
end
