$:.unshift File.join(File.dirname(__FILE__), 'web_resource_bundler')
require 'content_management/block_parser'
require 'content_management/block_data'
require 'content_management/css_url_rewriter'
require 'content_management/resource_file'

require 'file_manager'
require 'logger'
require 'filters'
require 'exceptions'
require 'rails_app_helpers'
require 'yaml'
require 'singleton'

module WebResourceBundler
  class Bundler
    include Singleton

    attr_reader :settings, :settings_correct, :filters
    @@logger = nil
    def self.logger
      @@logger
    end

    def initialize
      @filters = {} 
      @settings = nil
      @file_manager = FileManager.new('','') 
      @parser = BlockParser.new
      @@logger = nil 
      @settings_correct = false
    end

    #could be used also when settings are different on each request
    def set_settings(settings)
      #all methods user call from rails should not raise any exception
      begin
        @settings = settings
        if @settings[:resource_dir]
          @@logger = create_logger(@settings)
          unless @settings[:cache_dir]
            @settings[:cache_dir] = 'cache'
          end
          @file_manager.resource_dir, @file_manager.cache_dir = @settings[:resource_dir], @settings[:cache_dir]
          set_filters(@settings, @file_manager) 
          #used to determine if bundler in correct state and could be used
          @settings_correct = true
        else
          @settings_correct = false
        end
      rescue Exception => e
        @@logger.error("Incorrect settings initialization, #{settings}\n#{e.to_s}") if @@logger
        @settings_correct = false
      end
    end

    #main method to process html text block
    def process(block)
      if @settings_correct
        begin
          filters = filters_array
          #parsing html text block, creating BlockData instance
          block_data = @parser.parse(block)
          #if filters set and no bundle files exists we should process block data
          unless filters.empty? or bundle_upto_date?(block_data)
            #reading files content and populating block_data
            read_resources!(block_data)
            #applying filters to block_data
            block_data.apply_filters(filters)
            #writing resulted files with filtered content on disk
            write_files_on_disk(block_data)
            @@logger.info("files written on disk")
            return block_data
          end
          #bundle up to date, returning existing block with modified file names 
          block_data.apply_filters(filters)
          return block_data
        rescue Exceptions::WebResourceBundlerError => e
          @@logger.error(e.to_s)
          return nil
        rescue Exception => e
          @@logger.error(e.backtrace.join("\n") + "Unknown error occured: " + e.to_s)
          return nil
        end
      end
    end

    private

    #giving filters array in right sequence (bundle filter should be first)
    def filters_array
      filters = []
      %w{bundle_filter base64_filter cdn_filter}.each do |key|
        filters << @filters[key.to_sym] if @settings[key.to_sym][:use] and @filters[key.to_sym] 
      end
      filters
    end

    #creates filters or change their settings
    def set_filters(settings, file_manager)
      #common settings same for all filters
      common_sets = { 
        :resource_dir => settings[:resource_dir],
        :cache_dir => settings[:cache_dir]
      }
      #used to create filters
      filters_data = {
        :bundle_filter => 'BundleFilter',
        :base64_filter => 'ImageEncodeFilter',
        :cdn_filter => 'CdnFilter'
      }
      filters_data.each_pair do |key, filter_class|
        if settings[key] and settings[key][:use]
          filter_settings = settings[key].merge(common_sets)
          if @filters[key]
            @filters[key].set_settings(filter_settings)
          else
            #creating filter instance with settings
            @filters[key] = eval("Filters::" + filter_class + "::Filter").new(filter_settings, file_manager)
          end
        end
      end
      @filters
    end

    def create_logger(settings)
      begin
        #creating default log file in rails log directory called web_resource_bundler.log
        unless settings[:log_path]
          log_dir = File.expand_path('../log', settings[:resource_dir])
          log_name = 'web_resource_bundler.log'
          settings[:log_path] = File.join(log_dir, log_name)
          Dir.mkdir(log_dir) unless File.exist?(log_dir)
        end
        file = File.open(settings[:log_path], File::WRONLY | File::APPEND | File::CREAT)
        logger = Logger.new(file)
      rescue Exception => e
        logger = Logger.new(STDOUT)
        logger.error("Can't create log file, check log path: #{settings[:log_path]}\n#{e.to_s}")
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
      block_data_copy.files.each do |file|
        return false unless File.exist?(File.join(@settings[:resource_dir], file.path))
      end
      true
    end

    #reads block data resource files content from disk and populating block_data
    def read_resources!(block_data)
      #iterating through each resource files
      block_data.files.each do |file|
        content = @file_manager.get_content(file.path)
        #rewriting url to absolute if content is css
        WebResourceBundler::CssUrlRewriter.rewrite_content_urls!(file.path, content) if file.type[:ext] == 'css'  
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
        File.open(File.join(@settings[:resource_dir], file.path), "w") do |f|
          f.print(file.content)
        end
      end
      block_data.child_blocks.each do |block|
        write_files_on_disk(block)
      end
    end

  end
end
