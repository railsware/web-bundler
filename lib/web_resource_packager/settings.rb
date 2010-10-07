module WebResourcePackager
  class Settings
    @@defaults = {
      :domen => 'domen.com',
      :protocol => 'http',
      :language => 'en'
    }

    def initialize(hash = {})
      @settings = @@defaults.merge(hash)
    end

    def [](i)
      @settings[i]
    end

    def method_missing(m, *args, &block)
      @settings[m.to_sym]
    end

  end
end
