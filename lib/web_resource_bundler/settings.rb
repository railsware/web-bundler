module WebResourceBundler
  class Settings

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
