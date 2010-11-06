module WebResourceBundler
  class FileManager

    def initialize(settings)
      @settings = settings
    end

    #here and below relative_path means path inside resource_dir
    def bundle_upto_date?(bundle_relative_path, files)
      return false unless exist?(bundle_relative_path) 
      bundle_date = access_time(bundle_relative_path)
      files.each do |relative_path|
        return false if access_time(relative_path) > bundle_date
      end
      true
    end

    def full_path(relative_path)
      File.join(@settings.resource_dir, relative_path)
    end

    def exist?(relative_path)
      File.exist? full_path(relative_path)
    end

    def access_time(relative_path)
      raise Exceptions::ResourceNotFoundError.new(full_path(relative_path)) unless exist?(relative_path) 
      File.ctime(full_path(relative_path)).to_f
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
