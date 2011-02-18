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

module WebResourceBundler
  class Bundler
    class << self

      attr_reader :filters, :logger

      #this method should called in initializer
      def setup(rails_root, rails_env)
        @parser = BlockParser.new
        settings = Settings.create_settings(rails_root, rails_env)
        if Settings.correct? 
          @logger = create_logger(settings[:log_path]) unless @logger
          @file_manager = FileManager.new(settings[:resource_dir], settings[:cache_dir])
          @filters = {}
          set_filters
        end
      end

      #this method should be used to turn on\off filters
      #on particular request
      def set_settings(settings)
        Settings.set(settings)
        set_filters
      end

      #main method to process html text block
      def process(block, domain, protocol)
        if Settings.correct? 
          begin
            filters = filters_array
            filters.each do |filter|
              Settings.set_request_specific_data!(filter.settings, domain, protocol)
            end
            block_data = @parser.parse(block)
            unless filters.empty? or bundle_upto_date?(block_data)
              read_resources!(block_data)
              block_data.apply_filters(filters)
              write_files_on_disk(block_data)
              @logger.info("files written on disk")
              return block_data
            end
            #bundle up to date, returning existing block with modified file names 
            block_data.apply_filters(filters)
            return block_data
          rescue Exceptions::WebResourceBundlerError => e
            @logger.error(e.to_s)
            return nil
          rescue Exception => e
            @logger.error(e.backtrace.join("\n") + "Unknown error occured: " + e.to_s)
            return nil
          end
        end
      end

      private

      #giving filters array in right sequence (bundle filter should be first)
      def filters_array
        filters = []
        %w{bundle_filter base64_filter cdn_filter}.each do |key|
          filters << @filters[key.to_sym] if Settings.settings[key.to_sym][:use] and @filters[key.to_sym] 
        end
        filters
      end

      #creates filters or change their settings
      def set_filters
        filters_data = {
          :bundle_filter => 'BundleFilter',
          :base64_filter => 'ImageEncodeFilter',
          :cdn_filter    => 'CdnFilter'
        }
        filters_data.each_pair do |key, filter_class| 
          #if filter settings are present and filter turned on
          if Settings.settings[key] and Settings.settings[key][:use] 
            filter_settings = Settings.filter_settings(key) 
            if @filters[key] 
              @filters[key].set_settings(filter_settings)
            else
              #creating filter instance with settings
              @filters[key] = eval("Filters::" + filter_class + "::Filter").new(filter_settings, @file_manager)
            end
          end
        end
        @filters
      end

      def create_logger(log_path)
        begin
          log_dir = File.dirname(log_path)
          #we should create log dir in rails root if it doesn't exist
          Dir.mkdir(log_dir) unless File.exist?(log_dir)
          file = File.open(log_path, File::WRONLY | File::APPEND | File::CREAT)
          logger = Logger.new(file)
        rescue Exception => e
          raise WebResourceBundler::Exceptions::LogCreationError.new(log_path, e.to_s) 
        end
        logger
      end

      #checks if resulted files exist for current @filters and block data
      def bundle_upto_date?(block_data)
        #we don't want to change original parsed block data
        #so just making a clone, using overriden clone method in BlockData
        block_data_copy = block_data.clone
        #modifying clone to obtain resulted files
        #apply_filters will just compute resulted file paths
        #because block_data isn't populated with files content yet
        block_data_copy.apply_filters(filters_array)
        #cheking if resulted files exist on disk in cache folder
        block_data_copy.all_files.each do |file|
          return false unless File.exist?(File.join(Settings.settings[:resource_dir], file.path))
        end
        true
      end

      #reads block data resource files content from disk and populating block_data
      def read_resources!(block_data)
        #iterating through each resource files
        block_data.files.each do |file|
          content = @file_manager.get_content(file.path)
          #rewriting url to absolute if content is css
          WebResourceBundler::CssUrlRewriter.rewrite_content_urls!(file.path, content) if file.types.first[:ext] == 'css'  
          file.content = content
        end
        #making the same for each child blocks, recursively
        block_data.child_blocks.each do |block|
          read_resources!(block)
        end
      end

      #recursive method to write all resulted files on disk
      def write_files_on_disk(block_data)
        @file_manager.create_cache_dir
        block_data.files.each do |file|
          File.open(File.join(Settings.settings[:resource_dir], file.path), "w") do |f|
            f.print(file.content)
          end
        end
        block_data.child_blocks.each do |block|
          write_files_on_disk(block)
        end
      end

    end
  end
end
