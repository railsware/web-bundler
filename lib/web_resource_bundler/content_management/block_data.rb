module WebResourceBundler
  class BlockData
    attr_accessor :css, :js, :inline_block, :condition, :child_blocks

    def initialize(condition = "")
      @inline_block = ""
      @css = ResourceBundle::Data.new ResourceBundle::CSS
      @js = ResourceBundle::Data.new ResourceBundle::JS
      @condition = condition
      @child_blocks = []
    end

    def clone
      clon = self.dup 
      clon.css = self.css.clone
      clon.js = self.js.clone
      if clon.child_blocks.size > 0
        clon.child_blocks = self.child_blocks.map do |block|
          block.clone
        end
      else
        clon.child_blocks = []
      end
      clon
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
            filter.apply(block_data)
          end
        end      
      end
    end

    def modify_resulted_files!(filters)
      unless filters.empty?
        filters.each do |filter|
          items = BlockData.all_childs(self)
          items.each do |block_data|
            filter.change_resulted_files!(block_data)
          end
        end
      end
    end

    def all_files
      @css.files.merge(@js.files)
    end

  end
end
