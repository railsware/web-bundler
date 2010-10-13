module ImageEncodeFilter
  module CssGenerator
    TAGS = ['background-image', 'background']
    SEPARATOR = 'A_SEPARATOR'
    PATTERN = /(#{TAGS.join('|')})\s*:\s*url\(\s*['|"]([^;]*)['|"]\s*\)\s*;/

    #get image url from string that matches tag
    def self.get_value(str)
      match = PATTERN.match(str)
      if match
        return match[2]
      else
        return nil
      end		
    end
    
    #checks if file exists and has css extension, if so - reads whole file in string
    def self.read_css_file(filename)
      if File.exist?(filename) and File.extname(filename) == ".css"
        File.read(filename) 
      else
        nil
      end
    end

    #iterates through all matches in file calling block for each match
    def self.iterate_through_matches(content, pattern)
      content.gsub(pattern) do |s|
        yield s
      end
    end
    
    #construct head of css file with definition of image data in base64
    def self.construct_header_for_ie(images)
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

    def self.construct_mhtml_link(file, domen)
      web_path = File.absolute_path(file).split("/public/")[-1]
      "http://#{domen + '/' + web_path}"
    end

    def self.write_css_file(filename, file_content)
      File.open(filename, "w") do |file|
        file.write file_content
      end
    end
    
    def self.new_filename(file, new_filename)
      File.join(File.dirname(file), new_filename)
    end

    def self.new_filename_for_ie(file, new_ie_filename)
      File.join(File.dirname(file), new_ie_filename) 
    end

    #generates new css file with images encoded in base64
    def self.encode_images(file, domen, new_filename, new_ie_filename, max_image_size, ie_only)
      css_file = self.read_css_file(file)
      #this hash holds all found unique images that should be encoded (has small size)
      images = {}	
      if css_file
        #changing current dir to css file dir - for images can be found properly
        content = self.iterate_through_matches(css_file, PATTERN) do |s|
          data = ImageData.new(get_value(s), File.dirname(file)) 
          if data.exist and data.size <= max_image_size
            #using image url as key to prevent one image be encoded many times
            images[data.url] = data unless images[data.path]
            s.sub!(PATTERN, "*#{TAGS[0]}: url(mhtml:#{self.construct_mhtml_link(file,domen)}!#{data.id});")
          else
            #if current image not found (html coder failed with url) we just leave this tag alone
            s.sub!(PATTERN, s)
          end
        end
        #actually generating file with new content
        self.write_css_file(new_filename_for_ie(file, new_ie_filename), self.construct_header_for_ie(images) + content)
        unless ie_only
          css_file = self.iterate_through_matches(css_file, PATTERN) do |s|
            data = images[get_value(s)]
            if data
              s.sub!(PATTERN, "#{TAGS[0]}:url('data:image/#{data.extension};base64,#{data.encoded}');")
            else
              s.sub!(PATTERN, s)
            end
          end
          self.write_css_file(new_filename(file, new_filename), css_file)
        end
      end

    end

  end
end
