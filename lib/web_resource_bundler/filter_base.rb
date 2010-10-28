module WebResourceBundler
  class FilterBase

    def initialize(settings, logger)
      @settings, @logger = settings, logger
    end

    def apply(unnecessary_var = nil)
      begin
        yield if block_given?
      rescue Exception => exception
        @logger.error("#{self.class}: #{exception}")
        begin
          self.cleanup
        rescue
          @logger.error("#{self.class}: cleanup failed")
        end
      end
    end

    def cleanup
      #this method used to delete unnecessary files if error occured
    end
  end
end
