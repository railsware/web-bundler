module WebResourceBundler
  module Filters
    #virtaul base class for filters
    class BaseFilter
      attr_reader :settings

      def initialize(settings, file_manager)
        @settings     = settings
        @file_manager = file_manager
      end

      def set_settings(settings)
        @settings = settings
      end

      def apply!(block_data = nil)
        raise NotImplementedError.new
      end

    end
  end
end
