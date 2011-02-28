$:.unshift File.join(File.dirname(__FILE__), 'web_resource_bundler')
require 'content_management/block_parser'
require 'content_management/block_data'
require 'content_management/css_url_rewriter'
require 'content_management/resource_file'

require 'file_manager'
require 'settings'
require 'logger'
require 'filters'
require 'exceptions'
require 'rails_app_helpers'
require 'yaml'
require 'digest/md5'
require 'uri'

module WebResourceBundler
  class Bundler

    class << self

      attr_reader :filters, :logger

      #this method should called in initializer
      def setup(rails_root, rails_env)
        settings = Settings.create_settings(rails_root, rails_env)
        return false unless Settings.correct? 
        @logger       = create_logger(settings[:log_path]) unless @logger
        @file_manager = FileManager.new(settings)
        @filters      = set_filters({}, @file_manager)
      end

      #this method should be used to turn on\off filters
      #on particular specific request
      def set_settings(settings)
        begin
          return false unless Settings.correct?(settings)
          Settings.set(settings)
          set_filters(@filters, @file_manager)
          @file_manager.set_settings(settings) 
          true
        rescue Exception => e
          @logger.error("Error occured while trying to change settings")
          false
        end
      end

      #main method to process html text block
      #filters settings changed with request specific data
      #html block parsed, and resulted bundle file names calculated
      #we don't want to read files from disk on each request
      #if bundle is not up to date block_data populated with files content
      #all filters applied and resulted block_data returnd
      #all exceptions resqued and logged so that no exceptions are raised in rails app
      def process(block, domain, protocol)
        return nil unless Settings.correct? 
        begin
          block_data = BlockParser.parse(block)
          filters    = filters_array(@filters)
          set_filters_request_specific_data!(filters, domain, protocol)
          if filters.any? && !bundle_upto_date?(block_data, @filters)
            read_resources!(block_data)
            block_data.apply_filters(filters)
            write_files_on_disk(block_data)
            @logger.info("files written on disk")
            return block_data
          end
          block_data.apply_filters(filters)
          block_data
        rescue Exception => e
          @logger.error("Error occured: " + e.to_s)
          nil
        end
      end

      private

      def set_filters_request_specific_data!(filters, domain, protocol)
        filters.each do |filter|
          Settings.set_request_specific_data!(filter.settings, domain, protocol)
        end
      end

      #giving filters array in right sequence (bundle filter should be first)
      def filters_array(filters_hash)
        filters = []
        [:bundle_filter, :base64_filter, :cdn_filter].each do |name|
          filters << filters_hash[name] if Settings.filter_used?(name) && filters_hash[name]
        end
        filters
      end

      #creates filters or change existing filter settings
      def set_filters(filters, file_manager)
        Filters::FILTER_NAMES.each_pair do |name, klass| 
          if Settings.filter_used?(name) 
            filter_settings = Settings.filter_settings(name) 
            filters[name] ? filters[name].set_settings(filter_settings) : filters[name] = klass::Filter.new(filter_settings, file_manager)
          end
        end
        filters
      end

      #creates logger object with new log file in rails_app/log
      #or appends to existing log file, log dir also created
      #all exception catched
      def create_logger(log_path)
        begin
          log_dir = File.dirname(log_path)
          Dir.mkdir(log_dir) unless File.exist?(log_dir)
          file   = File.open(log_path, File::WRONLY | File::APPEND | File::CREAT)
          logger = Logger.new(file)
        rescue Exception => e
          raise WebResourceBundler::Exceptions::LogCreationError.new(log_path, e.to_s) 
        end
        logger
      end

      #creates a clone of block_data to calculate resulted file names
      #all filters applied to block_data
      #if resulted bundle files exists - we considering bundle up to date
      def bundle_upto_date?(block_data, filters)
        block_data_copy = block_data.clone
        filters         = filters_array(filters)
        block_data_copy.apply_filters(filters)
        block_data_copy.all_files.each do |file|
          return false unless File.exist?(File.join(Settings.settings[:resource_dir], file.path))
        end
        true
      end

      #block_data and its childs (whole tree) populated with files content recursively
      #relative url in css files rewritten to absolute
      def read_resources!(block_data)
        block_data.files.each do |file|
          content = @file_manager.get_content(file.path)
          WebResourceBundler::CssUrlRewriter.rewrite_content_urls!(file.path, content) if file.type[:ext] == 'css'  
          file.content = content
        end
        block_data.child_blocks.each { |block| read_resources!(block) }
      end

      #recursive method to write all resulted files on disk
      def write_files_on_disk(block_data)
        @file_manager.create_cache_dir
        block_data.files.each        { |file| @file_manager.write_file(file.path, file.content) } 
        block_data.child_blocks.each { |block| write_files_on_disk(block)                       } 
      end

    end
  end
end
