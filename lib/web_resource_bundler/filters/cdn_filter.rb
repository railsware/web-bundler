module WebResourceBundler::Filters::CdnFilter
  class Filter < WebResourceBundler::Filters::BaseFilter
    def initialize(settings, logger, file_manager)
      super(settings, logger)
      @file_manager = file_manager
    end

    def apply(block_data)
      resulted_files = {}
      block_data.css.files.each_pair do |path, content| 
        resulted_files[new_file_path(path)] = rewrite_content_urls!(path, content)
      end
      block_data.css.files = resulted_files
    end

    def new_file_path(path)
      File.join(File.dirname(path), 'cdn_' + File.basename(path))
    end

    def host_for_image(image_url)
      if @settings.protocol == 'https' 
        hosts = @settings.https_hosts
      else
        hosts = @settings.http_hosts
      end
      host_index = image_url.hash % hosts.size
      hosts[host_index]
    end

    def rewrite_content_urls!(file_path, content)
      content.gsub!(/url\s*\(['|"]?([^\)'"]+)['|"]?\)/) do
        matched_url = $1
        if matched_url.match(/\.(jpg|gif|png|jpeg|bmp)/)
          url = CssUrlRewriter.rewrite_relative_path(file_path, matched_url)
          host = host_for_image(url)
          s = "url('#{host}#{url}')"
        end 
      end
    end

    def change_resulted_files!(resources)
      resulted_files = {}
      resources[:css].files.each_key do |path|
        resulted_files[new_file_path(path)] = ""
      end
      resources[:css].files = resulted_files
    end

  end
end
