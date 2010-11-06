module WebResourceBundler
  class BundledContentConstructor

    class << self
      def construct_js_link(path)
        "<script src = \"#{path}\" type=\"text/javascript\"></script>"
      end

      def construct_css_link(path)
        "<link href = \"#{path}\" media=\"screen\" rel=\"Stylesheet\" type=\"text/css\" />"
      end

      def construct_block(block_data)
        result = ""
        block_data.css.files.each_key do |url|
          result += construct_css_link(url)
          result += "\n"
        end
        block_data.js.files.each_key do |url|
          result += construct_js_link(url)
          result += "\n"
        end
        result += block_data.inline_block
        block_data.child_blocks.each do |block|
          result += construct_block(block)
        end
        unless block_data.condition.empty?
          result = "<!--#{block_data.condition}>" + result + "<![endif]-->"
        end
        result
      end
    end

  end

end
