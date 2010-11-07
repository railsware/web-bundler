$:.unshift File.join(File.dirname(__FILE__), 'web_resource_bundler')
require 'content_management/block_parser'
require 'content_management/block_data'
require 'content_management/css_url_rewriter'
require 'content_management/resource_bundle'
require 'content_management/bundled_content_constructor'

require 'settings'
require 'file_manager'
require 'logger'
require 'filters'
require 'exceptions'

module WebResourceBundler
  class Bundler
    def initialize(settings = {})
      @settings = Settings.new settings
      file = File.open(@settings.log_path, File::WRONLY | File::APPEND | File::CREAT)
      @logger = Logger.new(file)
      @file_manager = FileManager.new @settings
      @parser = BlockParser.new
      @filters = {
        :bundler => Filters::BundleFilter::Filter.new(@settings, @file_manager),
        :base64 => Filters::ImageEncodeFilter::Filter.new(@settings, @file_manager),
        :cdn => Filters::CdnFilter::Filter.new(@settings, @file_manager)
      }
    end

    def process(block)
      begin
        block_data = @parser.parse(block)
        filters = build_filters 
        unless filters.empty? or bundle_upto_date?(filters, block_data)
          read_resources!(block_data)
          block_data.apply_filters(filters)
          write_files_on_disk(block_data)
          return BundledContentConstructor.construct_block(block_data)
        end
        #bundle up to date, returning existing block 
        return block
      rescue Exception => e
        @logger.error(e.to_s)
        return block
      end
    end

    def build_filters
      filters = []
      filters << @filters[:bundler] if @settings.bundle_files
      filters << @filters[:base64] if @settings.encode_images
      filters << @filters[:cdn] if @settings.use_cdn and not @settings.encode_images
      return filters
    end

    def bundle_upto_date?(filters, block_data)
      #constructing a full copy of block_data to obtain resulted file names and do not modify original block_data
      files = block_data.get_resulted_files(filters)
      files.each do |path|
        return false unless @file_manager.exist?(path)
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
