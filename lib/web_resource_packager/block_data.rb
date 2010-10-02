require File.join(File.dirname(__FILE__), 'block_files')
module WebResourcePackager
  class BlockData
    attr_accessor :files, :inline_block, :condition, :child_blocks

    def initialize(condition = "")
      @inline_block = ""
      @files = BlockFiles.new
      @condition = condition
      @child_blocks = []
    end

    def get_content(additional_content = "")
      content = files.get_content + inline_block + condition
      unless child_blocks.empty?
        content += ((child_blocks.sort_by {|b| b.condition}).map {|block| block.condition + block.get_content}).join('|')
      end
      content + additional_content
    end


  end
end
