require 'base64'
module WebResourceBundler
  module Filters
    module ImageEncodeFilter
      #ImageData contains info about image found in css files
    	class ImageData

        MHTML_CONTENT_LOCATION = 'Content-Location:'
        MHTML_CONTENT_ENCODING = 'Content-Transfer-Encoding:base64'

    		attr_reader :extension, :id, :path, :exist, :url

    		def initialize(url, folder)
          @url   = url
    			@path  = File.join(folder, url) 
          @exist = File.file?(@path)
          report_problem_if_file_not_found
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
    				result << MHTML_CONTENT_LOCATION << @id << "\n"
    				result <<	MHTML_CONTENT_ENCODING << "\n\n"
    				result << encoded << "\n\n"
    			end
    		end

    		def encoded
    			return nil unless @exist
    			Base64.encode64(File.read(@path)).gsub("\n", '')
    		end

        private
        
        def report_problem_if_file_not_found
          if WebResourceBundler::Bundler.logger && !URI.parse(@path).absolute? && !@exist
            WebResourceBundler::Bundler.logger.info("Image not found #{@path}")
          end
        end

    	end
    end
  end
end
