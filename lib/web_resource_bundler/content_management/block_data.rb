module WebResourceBundler
  class BlockData
    attr_accessor :files, :inline_block, :condition, :child_blocks

    def initialize(condition = "")
      @inline_block = ""
      @files        = []
      @condition    = condition
      @child_blocks = []
    end

    def styles
      @files.select { |f| f.type[:ext] == 'css' } 
    end

    def scripts
      @files.select { |f| f.type[:ext] == 'js'}
    end

    def base64_styles
      @files.select { |f| WebResourceBundler::ResourceFileType::CSS_TYPES.include?(f.type)}
    end

    def mhtml_styles
      @files.select { |f| WebResourceBundler::ResourceFileType::MHTML_TYPES.include?(f.type)}
    end

    def clone
      clon              = self.dup 
      clon.files        = self.files.map {|f| f.clone}
      clon.child_blocks = clon.child_blocks.any? ? self.child_blocks.map { |block| block.clone } : []
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
      result
    end

    def apply_filters(filters)
      if filters.any?
        filters.each do |filter|
          items = BlockData.all_childs(self)
          items.each { |block_data| filter.apply!(block_data) } 
        end      
      end
    end

  end
end
