require 'base64'
module WebResourceBundler
  module Filters
    module ImageEncodeFilter
      #ImageData contains info about image found in css files
    	class ImageData
    		MAX_RAND_FOR_ID = 10000
    		attr_reader :extension, :id, :path, :exist, :url

    		def initialize(url, folder)
          @url = url
          #computing absolute file path using folder of css file
    			@path = File.join(folder, url) 
          if File.file?(@path)
    			  @exist = true 
          else 
            @exist = false
          end
          if WebResourceBundler::Bundler.logger and !@path.include?('://') and !@exist
            WebResourceBundler::Bundler.logger.info("Image not found #{@path}")
          end
    			if @exist
    				@size = File.size(@path)
            WebResourceBundler::Bundler.logger.info("Error here #{@path}")
    				name, @extension = File.basename(@path).split('.')
    				#id is a filename plus random number - to support uniqueness
    				@id = name + rand(MAX_RAND_FOR_ID).to_s
    			end
    		end

        def size
          @size / 1024
        end

    		#constructs part of css header with data for current image
    		def construct_mhtml_image_data(separator)
    			if @exist
    				result = separator + "\n"
    				result << 'Content-Location:' << @id << "\n"
    				result <<	'Content-Transfer-Encoding:base64' << "\n\n"
    				result << encoded << "\n\n"
    			end
    		end

    		def encoded
    			return nil unless @exist
          #return 'iVBORw0KGgoAAAANSUhEUgAAAF8AAABfAQMAAAC0gom2AAAABlBMVEX///8BAQE6HLieAAAA4UlEQVQ4jcXTMa7DIAwG4L/KwAYXQOIa3rgS7wJJeoH0Smy9BlIu0G4MqH6OoqbLw3lbEQPfANjYAN8fkV8ID2KuKgjWlERFFip4AV/r+jpHGekfoGbPARuLq0c4HUg+tC6f5DrYjCl/HuhvGEz35u48n0BecGX20AG53svRSUcMz+rHCFdVINxyu+ThQSoIPzXMcQ9AgXdcXOZbVWEkiCZz0oEgNRvjvkfB5oWGGSqkcrElWp9ZxdYH0nzDu5V74MWUiffK6UCKxZ5DkuHj6A5gJRmzV66P7Tf6S0UiFd8ev8BJTrfU/sE4AAAAAElFTkSuQmCC'
    			Base64.encode64(File.read(@path)).gsub("\n", '')
    		end
    	end
    end
  end
end
