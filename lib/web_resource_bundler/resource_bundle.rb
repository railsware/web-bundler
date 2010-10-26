require 'digest/md5'
module WebResourceBundler::ResourceBundle

  CSS = {:name => 'style', :ext => 'css'}
  JS = {:name => 'script', :ext => 'js'}
  
  class Data
    attr_reader :type, :bundle_filename, :paths
    attr_accessor :files

    def initialize(type, filenames = [])
      @type = type
      @files = filenames
      @bundle_filename = ''
    end

    def get_md5(settings)
      items = [@files, settings.domain, settings.protocol]
      Digest::MD5.hexdigest(items.flatten.join('|'))
    end

    def bundle_filename(settings)
      if @bundle_filename.empty? and not @files.empty?
        items = [@type[:name] + '_' + get_md5(settings), settings.language, @type[:ext]]
        @bundle_filename = items.join('.') 
      end
     @bundle_filename 
    end

    def ie_bundle_filename(settings)
      'ie.' + bundle_filename(settings)
    end

  end
end
