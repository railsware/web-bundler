module WebResourceBundler::Filters::CompressFilter
  class Filter < WebResourceBundler::Filters::BaseFilter

    FILE_PREFIX = 'min_'

    def initialize(settings, file_manager)
      super(settings, file_manager)
      @js_compressor  = YUI::JavaScriptCompressor.new(:munge => settings[:obfuscate_js])
      @css_compressor = YUI::CssCompressor.new
    end

    def set_settings(settings)
      @settings = settings
      if @settings[:obfuscate_js] != settings[:obfuscate_js] 
        @js_compressor = YUI::JavaScriptCompressor.new(:munge => settings[:obfuscate_js]) 
      end
    end

    def apply!(block_data)
      compress_styles!(block_data.styles)
      compress_scripts!(block_data.scripts)
      block_data
    end

    protected

    def compress_scripts!(scripts)
      scripts.each do |file|
        file.content = @js_compressor.compress(file.content) unless file.content.empty?
        file.path    = new_js_path(file.path)
      end
    end

    def compress_styles!(styles)
      styles.each do |file|
        file.content = @css_compressor.compress(file.content) unless file.content.empty?
        file.path    = new_css_path(file.path)
      end
    end

    def new_css_path(path)
      @file_manager.add_name_prefix(path, FILE_PREFIX)
    end

    def new_js_path(path)
      @file_manager.add_name_prefix(path, FILE_PREFIX)
    end

  end
end
