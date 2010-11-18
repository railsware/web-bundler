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

    def apply_filters(filters)
      unless filters.empty?
        filters.each do |filter|
          filter.apply(self)
        end      
        @child_blocks.each do |b|
          b.apply_filters(filters)  
        end
      end
    end

    def modify_resulted_files!(filters)
      unless filters.empty?
        filters.each do |filter|
          filter.change_resulted_files!(self)
        end
        @child_blocks.each do |b|
          b.modify_resulted_files!(filters)
        end
      end
    end

    def all_files
      @css.files.merge(@js.files)
    end

  end
end
