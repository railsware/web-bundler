module WebResourceBundler::Exceptions
  class WebResourceBundlerError < Exception

    def initialize(message = "Unknown error occured")
      @message = message
    end

    def to_s
      @message
    end

  end

  class ResourceNotFoundError < WebResourceBundlerError
    def initialize(path)
      super "Resource #{path} not found"
    end
  end

  class NonExistentCssImage < WebResourceBundlerError
    def initialize(image_path)
      super "Css has url to incorrect image path: #{image_path}"
    end
  end

end
