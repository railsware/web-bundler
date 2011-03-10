module WebResourceBundler
  class FileManager
    attr_reader :resource_dir, :cache_dir

    def initialize(attributes)
      set_settings(attributes)
    end

    def set_settings(attributes)
      @resource_dir = attributes[:resource_dir]
      @cache_dir    = attributes[:cache_dir]
    end

    def full_path(relative_path)
      File.join(@resource_dir, relative_path)
    end

    def add_name_prefix(path, prefix)
      File.join(File.dirname(path), prefix + File.basename(path))
    end

    def exist?(relative_path)
      File.exist? full_path(relative_path)
    end

    def get_content(relative_path)
      raise Exceptions::ResourceNotFoundError.new(full_path(relative_path)) unless exist?(relative_path)
      File.read(full_path(relative_path))
    end

    def create_cache_dir
      path = File.join(@resource_dir, @cache_dir)
      unless File.exist?(path)
        Dir.mkdir(path)
      end
    end
    
    def write_file(path, content)
      File.open(full_path(path), "w") do |f|
        f.print(content)
      end
    end

  end
end
