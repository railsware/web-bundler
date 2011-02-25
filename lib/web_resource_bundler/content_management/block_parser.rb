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
        block.scan(URL_PATTERN).each do |attribute, path|
          if !URI.parse(path).absolute?
            resource = create_resource_file(attribute, path)
            files << resource if resource
          end
        end
        files
      end

      def create_resource_file(attribute, path)
        case attribute
          when "src" 
            then WebResourceBundler::ResourceFile.new_js_file(path) if File.extname(path) == '.js'
          when "href" 
            then WebResourceBundler::ResourceFile.new_css_file(path) if File.extname(path) == '.css'
        end
      end

    end 

  end
end
