module WebResourceBundler
  
  class ResourceFileType
    CSS = {:value => 1, :name => 'style', :ext => 'css'}
    JS = {:value => 2, :name => 'script', :ext => 'js'}
    MHTML = {:value => 3, :name => 'style', :ext => 'css'}
  end

  class ResourceFile  
    attr_reader :type
    attr_accessor :path, :content
    def initialize(type, path, content = "")
      @type = type
      @content = content
      @path = path
    end
    def self.new_js_file(path, content = "")
      ResourceFile.new(ResourceFileType::JS, path, content) 
    end
    def self.new_css_file(path, content = "")
      ResourceFile.new(ResourceFileType::CSS, path, content)
    end
    def self.new_mhtml_file(path, content = "")
      ResourceFile.new(ResourceFileType::MHTML, path, content)
    end
    def clone
      ResourceFile.new(self.type.dup, self.path.dup, self.content.dup)
    end
  end

end
