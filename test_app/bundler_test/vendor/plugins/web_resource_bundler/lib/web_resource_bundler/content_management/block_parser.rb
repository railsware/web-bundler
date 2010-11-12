module WebResourceBundler
  class BlockParser
    CONDITIONAL_BLOCK_PATTERN = /\<\!\-\-\s*\[\s*if[^>]*IE\s*\d*[^>]*\]\s*\>(.*?)\<\!\s*\[\s*endif\s*\]\s*\-\-\>/xmi
    CONDITION_PATTERN = /\<\!\-\-\s*(\[[^<]*\])\s*\>/
    LINK_PATTERN = /(\<(link|script[^>]*?src\s*=).*?(\>\<\/script\>|\>))/ 

    #parsing block content recursively
    #nested comments NOT supported
    #result is BlockData with conditional blocks in child_blocks
    def parse_block_with_childs(block, condition)
      block_data = BlockData.new(condition)
      block.gsub!(CONDITIONAL_BLOCK_PATTERN) do |s|
        new_block = CONDITIONAL_BLOCK_PATTERN.match(s)[1]
        new_condition = CONDITION_PATTERN.match(s)[1]
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
    def remove_links(block)
      block.gsub(LINK_PATTERN, "")
    end

    #looking for css and js files included and create BlockFiles with files paths
    def find_files(block)
      files = {:css => {}, :js => {}}
      block.scan(/(href|src) *= *["']([^"^'^\?]+)/i).each do |property, value|
        case property
          when "src" then files[:js][value] = "" 
          when "href" then files[:css][value] = "" 
        end
      end
      files
    end

    #just a short method to start parsing passed block
    def parse(block)
      parse_block_with_childs(block, "")
    end

  end
end
