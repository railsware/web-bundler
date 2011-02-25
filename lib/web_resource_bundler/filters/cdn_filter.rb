module WebResourceBundler::Filters::CdnFilter
  class Filter < WebResourceBundler::Filters::BaseFilter

		EXTENSTIONS_PATTERN = /\.(jpg|gif|png|jpeg|bmp)/
		FILE_PREFIX					= 'cdn_'

    def initialize(settings, file_manager)
      super(settings, file_manager)
    end

    def apply!(block_data)
      block_data.styles.each do |file| 
        rewrite_content_urls!(file.path, file.content) unless file.content.empty? 
        file.path = new_filepath(file.path)
      end
      block_data
    end

    def new_filepath(path)
      File.join(@settings[:cache_dir], FILE_PREFIX + File.basename(path))
    end

    #insures that image linked to one particular host  
		#host type depends on request protocol type
    def host_for_image(image_url)
      hosts = get_hosts
      index = image_url.hash % hosts.size
      hosts[index]
    end

		private

		def get_hosts
			key = @settings[:protocol] == 'https' ? :https_hosts : :http_hosts
			@settings[key]
		end

    def rewrite_content_urls!(file_path, content)
      content.gsub!(/url\s*\(['|"]?([^\)'"]+)['|"]?\)/) do |s|
        matched_url = $1
        #we shouldn't change url value for base64 encoded images
        if !(/base64/.match(s) || /mhtml/.match(s)) && matched_url.match(EXTENSTIONS_PATTERN)
          #using CssUrlRewriter method to get image url 
          url = WebResourceBundler::CssUrlRewriter.rewrite_relative_path(file_path, matched_url)
          host = host_for_image(url)
          s = "url('#{File.join(host, url)}')"
        else
          s
        end
      end
    end
    
  end
end
