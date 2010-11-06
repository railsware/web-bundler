module WebResourceBundler
  class Settings
    @@defaults = {
      :domain => 'domain.com',
      :protocol => 'http',
      :language => 'en',
      :bundle_files => true,
      :encode_images => true,
      :use_cdn => true,
      :max_image_size => 23, #kbytes
      :resource_dir => '/public',
      :cache_dir => '/cache',
      :http_hosts => ['http://booble.com'],
      :https_hosts => ['https://booble.com']
    }

    def initialize(hash = {})
      @settings = @@defaults.merge(hash)
    end

    def set(hash)
      @settings.merge!(hash)
    end

    def [](i)
      @settings[i]
    end

    def []=(i , v)
      @settings[i] = v 
    end

    def method_missing(m, *args, &block)
      m=m.to_s
      if /.*=\z/.match(m)
        @settings[m[0..-2].to_sym] = args[0] 
      else
        @settings[m.to_sym]
      end
    end

  end
end
