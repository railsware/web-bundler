module WebResourcePackager
  class BlockFiles
    attr_accessor :js_files, :css_files
    def initialize(js = [], css = [])
      @js_files, @css_files = js, css
    end
    def get_content
      (@css_files.sort + @js_files.sort).join('|')
    end

  end
end
