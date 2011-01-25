module WebResourceBundler
  class BlockData
    attr_accessor :files, :inline_block, :condition, :child_blocks

    def initialize(condition = "")
      @inline_block = ""
      @files = []
      @condition = condition
      @child_blocks = []
    end

    def styles
      @files.select do |f|
        !([WebResourceBundler::ResourceFileType::CSS, 
          WebResourceBundler::ResourceFileType::IE_CSS] & f.types).empty?
      end
    end

    def scripts
      @files.select {|f| f.types.include?(WebResourceBundler::ResourceFileType::JS)}
    end

    def clone
      clon = self.dup 
      clon.files = self.files.map {|f| f.clone}
      if clon.child_blocks.size > 0
        clon.child_blocks = self.child_blocks.map do |block|
          block.clone
        end
      else
        clon.child_blocks = []
      end
      clon
    end

    def all_files
      result = self.files
      self.child_blocks.each do |child|
        result += child.all_files
      end
      result
    end

    def self.all_childs(block_data)
      result = []
      result << block_data
      block_data.child_blocks.each do |child|
        result += BlockData.all_childs(child)
      end
      return result
    end

    def apply_filters(filters)
      unless filters.empty?
        filters.each do |filter|
          items = BlockData.all_childs(self)
          items.each do |block_data|
            filter.apply!(block_data)
          end
        end      
      end
    end

  end
end
