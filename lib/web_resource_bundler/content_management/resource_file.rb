module WebResourceBundler
  
  class ResourceFileType

    CSS					= {:value => 1 , :name => 'style'  , :ext => 'css'   } 
    JS					= {:value => 2 , :name => 'script' , :ext => 'js'    } 
    MHTML_CSS		= {:value => 3 , :name => 'style'  , :ext => 'css'   } 
    BASE64_CSS	= {:value => 4 , :name => 'style'  , :ext => 'css'   } 
    MHTML				= {:value => 5 , :name => 'mhtml'  , :ext => 'mhtml' } 

		CSS_TYPES		= [CSS, BASE64_CSS]
		MHTML_TYPES = [CSS, MHTML_CSS, MHTML]
  end

  class ResourceFile  

    attr_accessor :type, :path, :content

    def initialize(path, content, type)
      @type    = type
      @content = content
      @path    = path
    end

		class << self

			def new_js_file(path, content = "")
				ResourceFile.new(path, content, ResourceFileType::JS) 
			end

			def new_css_file(path, content = "")
				ResourceFile.new(path, content, ResourceFileType::CSS)
			end

			def new_mhtml_css_file(path, content = "")
				ResourceFile.new(path, content, ResourceFileType::MHTML_CSS)
			end

			def new_mhtml_file(path, content = "")
				ResourceFile.new(path, content, ResourceFileType::MHTML)
			end

		end
    
    def clone
      ResourceFile.new(self.path.dup, self.content.dup, self.type.dup)
    end

  end

end
