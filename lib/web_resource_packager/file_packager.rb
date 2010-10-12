module WebResourcePackager
  class FilePackager
    IMPORT_PTR = /\@import ['|"](.*?)['|"];/

    def initialize(settings)
      @settings = settings
    end

    def bundle_resource(data)
      path = bundle_file_path(data.bundle_filename(@settings))
      begin
        content = bundle_files(data.files)
        if content and not bundle_upto_date?(data)
          File.open(path, "w") do |file|
            file.puts content
          end
        end
        return path
      rescue
        return nil
        #something went wrong here
      end
    end

    #recursively iterates through all files and imported files
    #yielding content of each file if block provided
    #could be used to rewrite images urls and encode images with base64
    #directly to css file
    def bundle_files(urls = [])
      output = ""
      urls.each do |url|
        output << "/* --------- #{url} --------- */\n"
        begin
          file_path = file_path(url)
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
          output << "/* --------- END #{url} --------- */\n"
        rescue 
          return nil
        end
      end
      output
    end

    def bundle_file_path(filename)
      File.join(@settings.resource_dir, filename)
    end

    def file_path(url)
      File.join(@settings.resource_dir, url)  
    end

    def resource_exist?(url)
      File.exist?(file_path(url)) ? true : false
    end

    def bundle_file_exist?(filename)
      File.exist?(bundle_file_path(filename)) ? true : false
    end

    def bundle_upto_date?(data)
      bundle_filename = data.bundle_filename(@settings)
      bundle_path = bundle_file_path(bundle_filename)
      return false unless bundle_file_exist?(bundle_filename)
      bundle_date = File.ctime(bundle_path)
      data.files.each do |url|
        return false unless resource_exist?(url) and File.ctime(file_path(url)) < bundle_date
      end
      true
    end

    
  end
end
