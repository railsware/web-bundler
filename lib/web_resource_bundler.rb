$:.unshift File.join(File.dirname(__FILE__), 'web_resource_bundler')
require 'content_management/block_parser'
require 'content_management/block_data'
require 'content_management/css_url_rewriter'
require 'content_management/resource_bundle'
require 'content_management/bundled_content_constructor'

require 'settings'
require 'file_manager'
require 'singleton'
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
    end

    def set_settings(hash)
      @settings.set(hash)
    end

    def process(block)
      block_data = @parser.parse(block)
      filters = build_filters 
      unless bundle_upto_date?(filters, block_data)
        read_resources!(block_data)
        block_data.apply_filters(filters)
        write_files_on_disk(block_data)
        return BundledContentConstructor.construct_block(block_data)
      end
      #bundle up to date, returning existing block 
      return block
    end

    def build_filters
      filters = []
      if @settings.bundle_files
        filters << Filters::BundleFilter::Filter.new(@settings, @logger, @file_manager)
      end
      if @settings.encode_images
        filters << Filters::ImageEncodeFilter::Filter.new(@settings, @logger, @file_manager)
      end
      if @settings.use_cdn and not @settings.encode_images
        filters << Filters::CdnFilter::Filter.new(@settings, @logger, @file_manager)
      end
      return filters
    end

    def bundle_upto_date?(filters, block_data)
      #constructing a full copy of block_data to obtain resulted file names and do not modify original block_data
      block_data_copy = block_data.dup
      block_data_copy.css = block_data.css.dup
      block_data_copy.js = block_data.js.dup
      files = block_data_copy.get_resulted_files(filters)
      files.each do |path|
        return false unless @file_manager.exist?(path)
      end
      true
    end

    def read_resources!(block_data)
      block_data.css.files.each_key do |path|
        block_data.css.files[path] = @file_manager.get_content(path)
      end
      block_data.js.files.each_key do |path|
        block_data.js.files[path] = @file_manager.get_content(path)
      end
      block_data.child_blocks.each do |block|
        read_resources!(block)
      end
    end

    #recursive method to write all resulted files on disk
    def write_files_on_disk(block_data)
      block_data.all_files.each_pair do |path, content|
        File.open(File.join(@settings.resource_dir, path), "w") do |f|
          f.print(content)
        end
      end
      block_data.child_blocks.each do |block|
        write_files_on_disk(block)
      end
    end

  end
end
