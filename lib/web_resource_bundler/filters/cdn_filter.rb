module WebResourceBundler::Filters::CdnFilter
  class Filter < WebResourceBundler::Filters::BaseFilter

		FILE_PREFIX				= 'cdn_'
		IMAGE_URL_PATTERN	= /url\s*\(['|"]?([^\)'"]+\.(jpg|gif|png|jpeg|bmp))['|"]?\)/i

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

		private

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

		def get_hosts
			key = @settings[:protocol] == 'https' ? :https_hosts : :http_hosts
			@settings[key]
		end

		#rewrites image urls excluding mhtml and base64 urls
    def rewrite_content_urls!(file_path, content)
      content.gsub!(IMAGE_URL_PATTERN) do |s|
				url = WebResourceBundler::CssUrlRewriter.rewrite_relative_path(file_path, $1)
				host = host_for_image(url)
				s = url_css_tag(host, url) 
      end
    end

		def url_css_tag(host, url)
			"url('#{File.join(host, url)}')"
		end

  end
end
