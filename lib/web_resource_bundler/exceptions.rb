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

end
