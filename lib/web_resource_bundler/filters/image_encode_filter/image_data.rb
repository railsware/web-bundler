require 'base64'
module WebResourceBundler
  module Filters
    module ImageEncodeFilter
      #ImageData contains info about image found in css files
    	class ImageData
    		MAX_RAND_FOR_ID = 10000
    		attr_reader :extension, :id, :path, :exist, :url

    		def initialize(url, folder)
          @url   = url
    			@path  = File.join(folder, url) 
          @exist = File.file?(@path)
          if WebResourceBundler::Bundler.logger && !URI.parse(@path).absolute? && !@exist
            WebResourceBundler::Bundler.logger.info("Image not found #{@path}")
          end
    			if @exist
    				@size      = File.size(@path)
    				@id        = Digest::MD5.hexdigest(url) 
    				@extension = File.basename(@path).split('.').last
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
    			Base64.encode64(File.read(@path)).gsub("\n", '')
    		end
    	end
    end
  end
end
