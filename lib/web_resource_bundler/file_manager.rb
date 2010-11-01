module WebResourceBundler
  class FileManager

    def initialize(settings)
      @settings = settings
    end

    def bundle_upto_date?(bundle_url, files)
      return false unless exist?(bundle_url) 
      bundle_date = access_time(bundle_url)
      files.each do |url|
        return false if access_time(url) > bundle_date
      end
      true
    end

    def full_path(url)
      File.join(@settings.resource_dir, url)
    end

    def exist?(url)
      File.exist? full_path(url)
    end

    def access_time(url)
      File.ctime(full_path(url)).to_f if exist?(url)
    end

    def create_cache_dir
      path = File.join(@settings.resource_dir, @settings.cache_dir)
      unless File.exist?(path)
        Dir.mkdir(path)
      end
    end

  end
end
