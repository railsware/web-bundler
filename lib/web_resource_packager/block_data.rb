require File.join(File.dirname(__FILE__), 'block_files')
module WebResourcePackager
  class BlockData
    attr_accessor :files, :inline_block, :condition, :child_blocks

    def initialize(conditon)
      @inline_block = ""
      @files = BlockFiles.new
      @condition = condition
      @child_blocks = []
    end
  end
end
