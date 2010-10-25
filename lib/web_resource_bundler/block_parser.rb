module WebResourceBundler
  class BlockParser
    CONDITIONAL_BLOCK_PTR = /\<\!\-\-\s*\[\s*if[^>]*IE\s*\d*[^>]*\]\s*\>(.*?)\<\!\s*\[\s*endif\s*\]\s*\-\-\>/xmi
    CONDITION_PTR = /\<\!\-\-\s*(\[[^<]*\])\s*\>/
    LINK_PTR = /(\<(link|script[^>]*?src\s*=).*?(\>\<\/script\>|\>))/ 

    #parsing block content recursively
    #nested comments NOT supported
    #result is BlockData with conditional blocks in child_blocks
    def self.parse_block_with_childs(block, condition)
      block_data = BlockData.new(condition)
      block.gsub!(CONDITIONAL_BLOCK_PTR) do |s|
        new_block = CONDITIONAL_BLOCK_PTR.match(s)[1]
        new_condition = CONDITION_PTR.match(s)[1]
        block_data.child_blocks << parse_block_with_childs(new_block, new_condition)
        s = ""
      end
      files = find_files(block)
      block_data.css.files = files[:css]
      block_data.js.files = files[:js]
      block_data.inline_block = remove_links(block)
      block_data
    end

    #removing resource links from block
    #example: "<link href="bla"><script src="bla"></script>my inline content" => "my inline content"
    def self.remove_links(block)
      block.gsub(LINK_PTR, "")
    end

    #looking for css and js files included and create BlockFiles with files paths
    def self.find_files(block)
      files = {:css => [], :js => []}
      block.scan(/(href|src) *= *["']([^"^'^\?]+)/i).each do |property, value|
        case property
          when "src" then files[:js] << value
          when "href" then files[:css] << value
        end
      end
      files
    end

    #just a short method to start parsing passed block
    def self.parse(block)
      parse_block_with_childs(block, "")
    end

  end
end
