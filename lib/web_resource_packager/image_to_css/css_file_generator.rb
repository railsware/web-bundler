module ImageToCss
  module CssFileGenerator
    TAG = 'background-image'
    SEPARATOR = 'A_SEPARATOR'
    PATTERN = /#{TAG}\s*:\s*url\(\s*['|"]([^;]*)['|"]\s*\)\s*;/
    MHTML_FILE_ENDING = "_mhtml"
    BASE_FILE_ENDING = "_base64"

    #get image url from string that matches tag
    def self.get_value(str)
      match = PATTERN.match(str)
      if match
        return match[1]
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

    #iterates through all matches in file and yield block for each match
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
    
    def self.new_filename(file)
      File.absolute_path(file).sub(/\.css/, BASE_FILE_ENDING + ".css")
    end

    def self.new_filename_for_ie(file)
      File.absolute_path(file).sub(/\.css/, MHTML_FILE_ENDING + ".css")
    end

    #this method won't work if another file were encoded in the same directory?
    #so what it for?
    def self.already_encoded?(path)
      /.*#{BASE_FILE_ENDING}\.css\z/.match(path) or /.*#{MHTML_FILE_ENDING}\.css\z/.match(path)
    end

    #generates new css file with images encode in base64
    def self.generate(file, domen)
      css_file = self.read_css_file(file)
      #this hash holds all found unique images that should be encoded (has small size)
      images = {}	
      if css_file
        #changing current dir to css file dir - for images can be found properly
        content = self.iterate_through_matches(css_file, PATTERN) do |s|
          data = ImageData.new(get_value(s), File.dirname(file)) 
          if data.small_enough? 
            #using image url as key to prevent one image be encoded many times
            images[data.url] = data unless images[data.path]
            s.sub!(PATTERN, "*#{TAG}: url(mhtml:#{self.construct_mhtml_link(file,domen)}!#{data.id});")
          else
            #if current image not found (html coder failed with url) we just leave this tag alone
            s.sub!(PATTERN, s)
          end
        end
        #actually generating file with new content
        self.write_css_file(new_filename_for_ie(file), self.construct_header_for_ie(images) + content)
        css_file = self.iterate_through_matches(css_file, PATTERN) do |s|
        	data = images[get_value(s)]
          if data
         	  s.sub!(PATTERN, "#{TAG}:url('data:image/#{data.extension};base64,#{data.encoded}');")
          else
            s.sub!(PATTERN, s)
          end
        end
        self.write_css_file(new_filename(file), css_file)
      end

    end

  end
end
