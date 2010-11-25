module WebResourceBundler
  
  class ResourceFileType
    CSS = {:value => 1, :name => 'style', :ext => 'css'}
    JS = {:value => 2, :name => 'script', :ext => 'js'}
    MHTML = {:value => 3, :name => 'style', :ext => 'css'}
  end

  class ResourceFile  
    attr_reader :type
    attr_accessor :name, :content
    def initialize(type, name, content = "")
      @type = type
      @content = content
      @name = name
    end
    def self.new_js_file(name, content = "")
      ResourceFile.new(ResourceFileType::JS, name, content) 
    end
    def self.new_css_file(name, content = "")
      ResourceFile.new(ResourceFileType::CSS, name, content)
    end
    def self.new_mhtml_file(name, content = "")
      ResourceFile.new(ResourceFileType::MHTML, name, content)
    end
    def clone
      ResourceFile.new(self.type.dup, self.name.dup, self.content.dup)
    end
  end

end
