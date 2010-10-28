module WebResourceBundler
  class CdnFilter < WebResourceBundler::FilterBase
    def initialize(settings, logger)
      super(settings, logger)
      @file_manager = FileManager.new @settings
    end

    def apply(block_data)
      super do
        block_data.css.files.each { |f| insert_hosts_in_urls(f) }
      end
    end

    def insert_hosts_in_urls(file_url)
      path = @file_manager.full_path(file_url)
      raise ResourceNotFoundError.new(path) unless @file_manager.exist?(file_url)
      content = File.read(path)
      if content
        rewrite_content_urls(file_url, content)
      end
      File.open(path, "w") do |file|
        file.print content
      end
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

    def rewrite_content_urls(file_url, content)
      content.gsub!(/url\s*\(['|"]?([^\)'"]+)['|"]?\)/) do
        matched_url = $1
        if matched_url.match(/\.(jpg|gif|png|jpeg|bmp)/)
          url = CssUrlRewriter.rewrite_relative_path(file_url, matched_url)
          host = host_for_image(url)
          s = "url('#{host}#{url}')"
        end 
      end
    end
  end
end
