module WebResourceBundler
  module Filters
    class BaseFilter

      def initialize(settings, file_manager)
        @settings = settings
        @file_manager = file_manager
      end

      def apply(block_data = nil)
        #applies filter to block_data
      end

      #resource is hash {:css => ResourceBundle::Data, :js => ResourceBundle::Data}
      def change_resulted_files!(resource = nil)
        #this method changes resource file names to resulted files paths
        #used to determine if resulted files exist on disk
      end

    end
  end
end
