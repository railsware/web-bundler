$:.unshift File.join(File.dirname(__FILE__), 'web_resource_bundler')
require 'ordered_hash'
require 'content_management/block_parser'
require 'content_management/block_data'
require 'content_management/css_url_rewriter'
require 'content_management/bundled_content_constructor'
require 'content_management/resource_bundle'

require 'settings'
require 'file_manager'
require 'logger'
require 'filters'
require 'exceptions'
require 'rails_app_helpers'

module WebResourceBundler
  class Bundler

    #we don't want to init bundler with all filters on each request
    #this class var used to keep initialized bundler through requests
    @@instance = nil
    def self.instance
      @@instance
    end

    attr_reader :settings

    def initialize(settings)
      @settings = Settings.new settings
      #log file initialization, if something wrong - input in STDOUT
      begin
        file = File.open(@settings.log_path, File::WRONLY | File::APPEND | File::CREAT)
        @logger = Logger.new(file)
      rescue
        @logger = Logger.new(STDOUT)
      end
      @file_manager = FileManager.new @settings
      @parser = BlockParser.new
      #common settings same for all filters
      common_sets = { 
        :resource_dir => @settings.resource_dir, 
        :cache_dir => @settings.cache_dir
      }
      @filters = [] 
      #bundler filters initialization
      @filters << Filters::BundleFilter::Filter.new(@settings.bundle_filter.merge(common_sets), @file_manager) if @settings.bundle_filter
      @filters << Filters::ImageEncodeFilter::Filter.new(@settings.base64_filter.merge(common_sets), @file_manager) if @settings.base64_filter
      @filters << Filters::CdnFilter::Filter.new(@settings.cdn_filter.merge(common_sets), @file_manager) if @settings.cdn_filter
      #keep initialized bundler instance in class var 
      @@instance = self
    end

    #used to changed settings on each request, when settings contain some request specific data
    def set_settings(settings)
      @settings.set(settings)
      #settings should be changed in each filter
      @filters.each_pair do |key, filter|
        filter.set_settings(@settings[key]) if settings[:key]
      end
    end

    #main method to process html text block
    def process(block)
      begin
        #parsing html text block, creating BlockData instance
        block_data = @parser.parse(block)
        #if filters set and no bundle files exists we should process block data
        unless @filters.empty? or bundle_upto_date?(block_data)
          #reading files content and populating block_data
          read_resources!(block_data)
          #applying filters to block_data
          block_data.apply_filters(@filters)
          #writing resulted files with filtered content on disk
          write_files_on_disk(block_data)
          @logger.info("files written on disk")
          return block_data
        end
        #bundle up to date, returning existing block with modified file names 
        block_data.modify_resulted_files!(@filters)
        return block_data
      rescue Exceptions::WebResourceBundlerError => e
        @logger.error(e.to_s)
      rescue Exception => e
        @logger.error("Unknown error occured: " + e.to_s)
        return nil
      end
    end

    #checks if resulted files exist for current @filters and block data
    def bundle_upto_date?(block_data)
      #we don't want to change original parsed block data
      #so just making a clone, using overriden clone method in BlockData
      block_data_copy = block_data.clone
      #modifying clone to obtain resulted files
      block_data_copy.modify_resulted_files!(@filters)
      #cheking if resulted files exist on disk in cache folder
      block_data_copy.all_files.keys.each do |name|
        return false unless File.exist?(File.join(@settings.resource_dir, @settings.cache_dir, name))
      end
      true
    end

    #reads block data resource files content from disk and populating block_data
    def read_resources!(block_data)
      #iterating through each resource files
      [block_data.css, block_data.js].each do |data|
        data.files.each_key do |path|
          content = @file_manager.get_content(path)
          #rewriting url to absolute if content is css
          WebResourceBundler::CssUrlRewriter.rewrite_content_urls!(path, content) if File.extname(path) == '.css'  
          data.files[path] = content
        end
      end
      #making the same for each child blocks, recursively
      block_data.child_blocks.each do |block|
        read_resources!(block)
      end
    end

    #recursive method to write all resulted files on disk
    def write_files_on_disk(block_data)
      @file_manager.create_cache_dir
      block_data.all_files.each_pair do |name, content|
        File.open(File.join(@settings.resource_dir, @settings.cache_dir, name), "w") do |f|
          f.print(content)
        end
      end
      block_data.child_blocks.each do |block|
        write_files_on_disk(block)
      end
    end

  end
end
