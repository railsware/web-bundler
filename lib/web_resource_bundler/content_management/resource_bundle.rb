require 'digest/md5'
module WebResourceBundler::ResourceBundle

  CSS = {:name => 'style', :ext => 'css'}
  JS = {:name => 'script', :ext => 'js'}
  
  class Data
    attr_reader :type
    #hash, key - file path, value - file content
    attr_accessor :files

    def initialize(type, files = {}) 
      @type = type
      @files = files
    end
  end
end
