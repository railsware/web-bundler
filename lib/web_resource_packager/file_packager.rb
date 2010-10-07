module WebResourcePackager
  class FilePackager
    IMPORT_PTR = /\@import ['|"](.*?)['|"];/
    CACHE_DIR = '/cache'

    def initialize(dirname, settings)
      @settings = settings
      @dir = dirname
      if Dir.exist?(dirname) and not Dir.exist?(File.join(dirname,CACHE_DIR))
        Dir.mkdir(File.join(dirname, CACHE_DIR))
      end
    end

    def get_absolute_file_path(url)
      File.join(@dir, url)
    end

    def create_bundle(type, filenames)
      begin
        filename = get_bundle_file_name(type, filenames)
        path = get_bundle_file_path(filename)
        content = bundle_files(filenames)
        if content
          File.open(path, "w") do |file|
            file.puts content
          end
        end
      rescue
        #dirname isn't valid
      end
    end

    def get_bundle_file_path(filename)
      File.join(@dir, CACHE_DIR, filename)
    end

    #recursively iterates through all files and imported files
    #yielding content of each file if block provided
    #could be used to rewrite images urls and encode images with base64
    #directly to css file
    def bundle_files(filenames = [])
      output = ""
      filenames.each do |filename|
        output << "/* --------- #{filename} --------- */\n"
        begin
          file_path = get_absolute_file_path(filename)
          content = File.read(file_path)
          imported_files = []
          content.gsub!(IMPORT_PTR).each do |result|
            imported_file = IMPORT_PTR.match(result)[1]
            if imported_file
              imported_files << imported_file
            end
            result = ""
          end
          output << bundle_files(imported_files)
          output << (block_given? ? yield(file_path, content) : content)
          output << "/* --------- END #{filename} --------- */\n"
        rescue 
          return nil
        end
      end
      output
    end

    def get_md5(filenames = [], additional_data = nil)
      items = [filenames, @settings.domen, @settings.protocol]
      items << additional_data if additional_data
      Digest::MD5.hexdigest(items.flatten.join('|'))
    end

    def get_bundle_file_name(type, filenames = [])
      items = [type[:name] + '_' + get_md5(filenames), @settings.language, type[:ext]]
      items.join('.') 
    end
    
  end
end
