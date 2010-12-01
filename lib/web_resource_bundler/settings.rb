module WebResourceBundler
  class Settings
    @@defaults = {
      :cache_dir => 'cache',
      :base64_filter => {
        :max_image_size => 23, #kbytes
        :protocol => 'http',
        :domain => 'localhost:3000'
      },
      :bundle_filter => {
        :md5_additional_data => []
      },
      :cdn_filter => {
        :http_hosts => ['http://localhost:3000'],
        :https_hosts => ['https://localhost:3000']
      }
    }

    def initialize(hash = {})
      @settings = hash
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
