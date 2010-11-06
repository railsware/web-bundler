module WebResourceBundler
  module Filters
    class BaseFilter

      def initialize(settings, logger)
        @settings, @logger = settings, logger
      end

      def apply(block_data = nil)
        #applies filter to block_data
      end

      def change_resulted_files!(block_data = nil)
        #this method changes resource file names in block_data to resulted files paths
        #used to determine if resulted files exist
      end

    end
  end
end
