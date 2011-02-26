$:.unshift File.join(File.dirname(__FILE__), "/bundle_filter")

require 'bundle_filter/resource_packager'
require 'base_filter'

module WebResourceBundler::Filters::BundleFilter
  class Filter < WebResourceBundler::Filters::BaseFilter

    def initialize(settings, file_manager)
      super(settings, file_manager)
      @packager = ResourcePackager.new(@settings, @file_manager)
    end

    def apply!(block_data)
      new_files        =  []
      new_files        << create_css_bundle(block_data.styles) if block_data.styles.any?
      new_files        << create_js_bundle(block_data.scripts) if block_data.scripts.any?
      block_data.files =  new_files
      block_data
    end

    private

    #creates one bundle resource file from css files
    def create_css_bundle(styles)
      filename = css_bundle_filepath(styles)
      content  = @packager.bundle_files(styles)
      WebResourceBundler::ResourceFile.new_css_file(filename, content)
    end

    #creates one bundle resource file from js files
    def create_js_bundle(scripts)
      filename = js_bundle_filepath(scripts)
      content  = @packager.bundle_files(scripts)
      WebResourceBundler::ResourceFile.new_js_file(filename, content)
    end

    def get_md5(files)
      items = [(files.map {|f| f.path }).sort]
      items << @settings[:protocol]
      items << @settings[:domain]
      items += @settings[:md5_additional_data] if @settings[:md5_additional_data]
      Digest::MD5.hexdigest(items.flatten.join('|'))
    end

    def bundle_filepath(type, files)
      return nil if files.empty?
      items = [type[:name] + '_' + get_md5(files)]
      items += @settings[:filename_additional_data] if @settings[:filename_additional_data]
      items << type[:ext]
      File.join(@settings[:cache_dir], items.join('.'))
    end

    #just aliases to simplify code
    def css_bundle_filepath(files)
      bundle_filepath(WebResourceBundler::ResourceFileType::CSS, files)
    end

    def js_bundle_filepath(files)
      bundle_filepath(WebResourceBundler::ResourceFileType::JS, files)
    end

  end
end
