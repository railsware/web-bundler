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
        new_css_file = bundle_filename(block_data.css.type, block_data.css.files.keys)
        new_css_content = @packager.bundle_files(block_data.css.files)
        block_data.css.files = { new_css_file => new_css_content }
      end
      unless block_data.js.files.empty?
        new_js_file = bundle_filename(block_data.js.type, block_data.js.files.keys)
        new_js_content = @packager.bundle_files(block_data.js.files)
        block_data.js.files = { new_js_file => new_js_content }
      end
    end

    def change_resulted_files(resources)
      resources[:css] = [ bundle_filename(ResourceBundle::CSS, resources[:css]) ]
      resources[:js] = [ bundle_filename(ResourceBundle::JS, resources[:js]) ]
      resources
    end

    def get_md5(files)
      items = [files, @settings.domain, @settings.protocol]
      Digest::MD5.hexdigest(items.flatten.join('|'))
    end

    def bundle_filename(type, files)
      unless files.empty?
        items = [type[:name] + '_' + get_md5(files), @settings.language, type[:ext]]
        return items.join('.') 
      else
        return nil
      end
    end

  end
end
