module WebResourceBundler
  module Filters
    #virtaul base class for filters
    class BaseFilter
      attr_reader :settings

      def initialize(settings, file_manager)
        @settings = Settings.new(settings)
        @file_manager = file_manager
      end

      def set_settings(settings)
        @settings.set(settings)
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
