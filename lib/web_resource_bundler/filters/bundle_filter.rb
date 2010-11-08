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

    def apply(block_data)
      unless block_data.css.files.empty?
        new_css_file = bundle_filename(block_data.css)
        new_css_content = @packager.bundle_files(block_data.css.files)
        block_data.css.files = { new_css_file => new_css_content }
      end
      unless block_data.js.files.empty?
        new_js_file = bundle_filename(block_data.js)
        new_js_content = @packager.bundle_files(block_data.js.files)
        block_data.js.files = { new_js_file => new_js_content }
      end
    end

    def change_resulted_files!(block_data)
      block_data.css.files = { bundle_filename(block_data.css) => "" }
      block_data.js.files = { bundle_filename(block_data.js)=> "" }
    end

    def get_md5(resource_data)
      items = [resource_data.files.keys, @settings.domain, @settings.protocol]
      Digest::MD5.hexdigest(items.flatten.join('|'))
    end

    def bundle_filename(resource_data)
      type = resource_data.type
      unless resource_data.files.keys.empty?
        items = [type[:name] + '_' + get_md5(resource_data), @settings.language, type[:ext]]
        return items.join('.') 
      else
        return nil
      end
    end

  end
end
