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
          b.apply_filters filters  
        end
      end
    end

  end
end
