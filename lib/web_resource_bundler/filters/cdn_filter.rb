module WebResourceBundler::Filters::CdnFilter
  class Filter < WebResourceBundler::Filters::BaseFilter
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
      File.join(@settings[:cache_dir], 'cdn_' + File.basename(path))
    end

    #insures that image linked to one particular host  
    def host_for_image(image_url)
      #hosts are different depending on protocol 
      if @settings[:protocol] == 'https' 
        hosts = @settings[:https_hosts]
      else
        hosts = @settings[:http_hosts]
      end
      #getting host based on image url hash
      host_index = image_url.hash % hosts.size
      hosts[host_index]
    end

    def rewrite_content_urls!(file_path, content)
      content.gsub!(/url\s*\(['|"]?([^\)'"]+)['|"]?\)/) do |s|
        matched_url = $1
        #we shouldn't change url value for base64 encoded images
        if not (/base64/.match(s) or /mhtml/.match(s)) and matched_url.match(/\.(jpg|gif|png|jpeg|bmp)/)
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
