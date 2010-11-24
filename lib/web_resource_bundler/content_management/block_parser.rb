module WebResourceBundler
  class BlockParser
    CONDITIONAL_BLOCK_PATTERN = /<!--\s*\[\s*if[^>]*IE\s*\d*[^>]*\]\s*>(.*?)<!\s*\[\s*endif\s*\]\s*-->/xmi
    CONDITION_PATTERN = /<!--\s*(\[[^<]*\])\s*>/
    LINK_PATTERN = /(<(link|script[^>]*?src\s*=).*?(><\/script>|>))/
    URL_PATTERN = /(href|src) *= *["']([^"'?]+)/i

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
      inline_block = block.gsub(LINK_PATTERN) do |s|
        extension = File.extname(URL_PATTERN.match(s)[2])
        if /\.js|\.css/.match(extension) and not s.include?('://')
          #we should delete link to local css or js resource
          '' 
        else
          #link to remote resource should be kept
          s
        end
      end
      return inline_block
    end

    #looking for css and js files included and create BlockFiles with files paths
    def find_files(block)
      files = {:css => OrderedHash.new, :js => OrderedHash.new}
      block.scan(URL_PATTERN).each do |property, value|
        unless value.include?('://') 
          case property
            when "src" then files[:js][value] = "" if File.extname(value) == '.js'
            when "href" then files[:css][value] = "" if File.extname(value) == '.css'
          end
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
