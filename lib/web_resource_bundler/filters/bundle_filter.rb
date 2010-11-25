$:.unshift File.join(File.dirname(__FILE__), "/bundle_filter")
require 'bundle_filter/resource_packager'
require 'base_filter'
require 'digest/md5'
module WebResourceBundler::Filters::BundleFilter
  class Filter < WebResourceBundler::Filters::BaseFilter

    def initialize(settings, file_manager)
      super(settings, file_manager)
      @packager = ResourcePackager.new(@settings, @file_manager)
    end

    def apply!(block_data)
      new_files = []
      unless block_data.styles.empty?
        new_css_filename = css_bundle_filename(block_data.styles)
        new_css_content = @packager.bundle_files(block_data.styles)
        new_css_file = WebResourceBundler::ResourceFile.new_css_file(new_css_filename, new_css_content)
        new_files << new_css_file 
      end
      unless block_data.scripts.empty?
        new_js_filename = js_bundle_filename(block_data.scripts)
        new_js_content = @packager.bundle_files(block_data.scripts)
        new_js_file = WebResourceBundler::ResourceFile.new_js_file(new_js_filename, new_js_content)
        new_files << new_js_file
      end
      block_data.files = new_files
      block_data
    end

    def change_resulted_files!(block_data)
      new_files = []
      if block_data.styles.size > 0
        new_files << WebResourceBundler::ResourceFile.new_css_file(css_bundle_filename(block_data.styles))
      end
      if block_data.scripts.size > 0
        new_files << WebResourceBundler::ResourceFile.new_js_file(js_bundle_filename(block_data.scripts))
      end
      block_data.files = new_files
      block_data
    end

    def get_md5(files)
      items = [(files.map {|f| f.name }).sort]
      items += @settings.md5_additional_data if @settings.md5_additional_data
      Digest::MD5.hexdigest(items.flatten.join('|'))
    end

    def bundle_filename(type, files)
      unless files.empty?
        items = [type[:name] + '_' + get_md5(files)]
        items += @settings.filename_additional_data if @settings.filename_additional_data
        items << type[:ext]
        return items.join('.') 
      else
        return nil
      end
    end

    #just aliases to simplify code
    def css_bundle_filename(files)
      bundle_filename(WebResourceBundler::ResourceFileType::CSS, files)
    end

    def js_bundle_filename(files)
      bundle_filename(WebResourceBundler::ResourceFileType::JS, files)
    end

  end
end
