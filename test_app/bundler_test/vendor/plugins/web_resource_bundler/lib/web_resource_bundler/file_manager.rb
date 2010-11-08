module WebResourceBundler
  class FileManager

    def initialize(settings)
      @settings = settings
    end

    def full_path(relative_path)
      File.join(@settings.resource_dir, relative_path)
    end

    def exist?(relative_path)
      File.exist? full_path(relative_path)
    end

    def get_content(relative_path)
      raise Exceptions::ResourceNotFoundError.new(full_path(relative_path)) unless exist?(relative_path)
      File.read(full_path(relative_path))
    end

    def create_cache_dir
      path = File.join(@settings.resource_dir, @settings.cache_dir)
      unless File.exist?(path)
        Dir.mkdir(path)
      end
    end

  end
end
