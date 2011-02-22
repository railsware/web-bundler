module WebResourceBundler
  module BlockParser

    CONDITIONAL_BLOCK_PATTERN = /<!--\s*\[\s*if[^>]*IE\s*\d*[^>]*\]\s*>(.*?)<!\s*\[\s*endif\s*\]\s*-->/xmi
    CONDITION_PATTERN         = /<!--\s*(\[[^<]*\])\s*>/
    LINK_PATTERN              = /(<(link|script[^>]*?src\s*=).*?(><\/script>|>))/
    URL_PATTERN               = /(href|src) *= *["']([^"'?]+)/i

    class << self

      #just a short method to start parsing block
      def parse(block)
        parse_block_with_childs(block, "")
      end

      private

      #parsing block content recursively
      #nested comments NOT supported
      #result is BlockData with conditional blocks in child_blocks
      def parse_block_with_childs(block, condition)
        block_data = BlockData.new(condition)
        block.gsub!(CONDITIONAL_BLOCK_PATTERN) do |s|
          new_block     = CONDITIONAL_BLOCK_PATTERN.match(s)[1]
          new_condition = CONDITION_PATTERN.match(s)[1]
          block_data.child_blocks << parse_block_with_childs(new_block, new_condition)
          ""
        end
        block_data.files        = find_files(block)
        block_data.inline_block = remove_links(block)
        block_data
      end

      #removing resource links from block
      #example: "<link href="bla"><script src="bla"></script>my inline content" => "my inline content"
      def remove_links(block)
        inline_block = block.gsub(LINK_PATTERN) do |s|
          url       = URL_PATTERN.match(s)[2]
          extension = File.extname(url)
          /\.js|\.css/.match(extension) && !URI.parse(url).absolute? ? '' : s
        end
        inline_block
      end

      #looking for css and js files included and create BlockFiles with files paths
      def find_files(block)
        files = []
        block.scan(URL_PATTERN).each do |property, value|
          if !URI.parse(value).absolute?
            case property
              when "src" 
                then files << WebResourceBundler::ResourceFile.new_js_file(value)  if File.extname(value) == '.js'
              when "href" 
                then files << WebResourceBundler::ResourceFile.new_css_file(value) if File.extname(value) == '.css'
            end
          end
        end
        files
      end

    end 

  end
end
