module WebResourceBundler
  
  class ResourceFileType
    CSS = {:value => 1, :name => 'style', :ext => 'css'}
    JS = {:value => 2, :name => 'script', :ext => 'js'}
    IE_CSS = {:value => 3, :name => 'style', :ext => 'css'}
    MHTML = {:value => 4, :name => 'style', :ext => 'mhtml'}
  end

  class ResourceFile  
    attr_accessor :types #array of ResourceFileType's objects
    attr_accessor :path, :content
    def initialize(path, content, *types)
      @types = types.flatten
      @content = content
      @path = path
    end
    def self.new_js_file(path, content = "")
      ResourceFile.new(path, content, ResourceFileType::JS) 
    end
    def self.new_css_file(path, content = "")
      ResourceFile.new(path, content, ResourceFileType::CSS)
    end
    def self.new_ie_css_file(path, content ="")
      ResourceFile.new(path, content, ResourceFileType::IE_CSS)
    end
    def self.new_style_file(path, content ="")
      ResourceFile.new(path, content, ResourceFileType::CSS, ResourceFileType::IE_CSS)
    end
    def self.new_mhtml_file(path, content = "")
      ResourceFile.new(path, content, ResourceFileType::MHTML)
    end
    def clone
      ResourceFile.new(self.path.dup, self.content.dup, self.types.dup)
    end
  end

end
