$:.unshift File.join(File.dirname(__FILE__), 'web_resource_bundler')
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

    @@instance = nil
    def self.instance
      @@instance
    end
    attr_reader :settings
    def initialize(settings)
      @settings = Settings.new settings
      begin
        file = File.open(@settings.log_path, File::WRONLY | File::APPEND | File::CREAT)
        @logger = Logger.new(file)
      rescue
        @logger = Logger.new(STDOUT)
      end
      @file_manager = FileManager.new @settings
      @parser = BlockParser.new
      common_sets = { 
        :resource_dir => @settings.resource_dir, 
        :cache_dir => @settings.cache_dir
      }
      @filters = [] 
      @filters << Filters::BundleFilter::Filter.new(@settings.bundle_filter.merge(common_sets), @file_manager) if @settings.bundle_filter
      @filters << Filters::ImageEncodeFilter::Filter.new(@settings.base64_filter.merge(common_sets), @file_manager) if @settings.base64_filter
      @filters << Filters::CdnFilter::Filter.new(@settings.cdn_filter.merge(common_sets), @file_manager) if @settings.cdn_filter
      @@instance = self
    end

    def set_settings(settings)
      @settings.set(settings)
      @filters.each_pair do |key, filter|
        filter.set_settings(@settings[key]) if settings[:key]
      end
    end

    def process(block)
      begin
        block_data = @parser.parse(block)
        unless @filters.empty? or bundle_upto_date?(block_data)
          read_resources!(block_data)
          block_data.apply_filters(@filters)
          write_files_on_disk(block_data)
          return BundledContentConstructor.construct_block(block_data, @settings)
        end
        #bundle up to date, returning existing block 
        block_data.modify_resulted_files!(@filters)
        return block_data
      rescue Exception => e
        @logger.error(e.backtrace.join("\n")+e.to_s)
        return nil
      end
    end

    def bundle_upto_date?(block_data)
      block_data_copy = block_data.clone
      block_data_copy.modify_resulted_files!(@filters)
      block_data_copy.all_files.keys.each do |name|
        return false unless File.exist?(File.join(@settings.resource_dir, @settings.cache_dir, name))
      end
      true
    end

    def read_resources!(block_data)
      [block_data.css, block_data.js].each do |data|
        data.files.each_key do |path|
          content = @file_manager.get_content(path)
          #rewriting url to absolute if content is css
          WebResourceBundler::CssUrlRewriter.rewrite_content_urls!(path, content) if File.extname(path) == '.css'  
          data.files[path] = content
        end
      end
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
