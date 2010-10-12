module WebResourcePackager
  class Settings
    @@defaults = {
      :domen => 'domen.com',
      :protocol => 'http',
      :language => 'en',
      :encode_images => true,
      :max_image_size => 23, #kbytes
      :resource_dir => '/public'
    }

    def initialize(hash = {})
      @settings = @@defaults.merge(hash)
    end

    def set(hash)
      @settings = @settings.merge(hash)
    end

    def [](i)
      @settings[i]
    end

    def []=(i , v)
      @settings[i] = v 
    end

    def method_missing(m, *args, &block)
      if /.*=\z/.match(m)
        @settings[m[0..-2].to_sym] = args[0] 
      else
        @settings[m.to_sym]
      end
    end

  end
end
