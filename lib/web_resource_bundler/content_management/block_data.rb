require File.join(File.dirname(__FILE__), 'resource_bundle')
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

    def get_resulted_files(filters)
      unless filters.empty?
        resources = {:css => @css.dup, :js => @js.dup, :condition => @condition.dup} 
        filters.each do |filter|
          filter.change_resulted_files!(resources)
        end
        files = resources[:css].files.keys + resources[:js].files.keys 
        @child_blocks.each do |b|
          files += b.get_resulted_files(filters)
        end
      end
      files
    end

    def all_files
      @css.files.merge(@js.files)
    end

  end
end
