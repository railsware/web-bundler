module WebResourceBundler
  module Filters
    module ImageEncodeFilter
      #ImageData contains info about image found in css files
    	class ImageData
    		#maximum file size allowed to be encoded
    		MAX_SIZE = 1024*10 #10 kbytes
    		MAX_RAND_FOR_ID = 10000
    		attr_reader :extension, :id, :path, :exist, :url

    		def initialize(url, folder)
          @url = url
          #computing absolute file path using folder of css file
    			@path = File.join(folder, url) 
    			@exist = File.exist?(@path)
    			if @exist
    				@size = File.size(@path)
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
    				result += "Content-Location:" + @id + "\n"
    				result +=	"Content-Transfer-Encoding:base64" + "\n"
    				result += encoded + "\n\n"
    			end
    		end

    		def encoded
    			return nil unless @exist
    			Base64.encode64(File.read(@path)).gsub("\n", '')
    		end
    	end
    end
  end
end
