module WebResourcePackager
  class FilePackager
    IMPORT_PTR = /\@import ['|"](.*?)['|"];/

    def initialize(dirname)
      @dir = dirname
    end

    def get_absolute_file_path(url)
      File.join(@dir, url)
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
          output << "/* FILE READ ERROR! */\n"
          next
        end
      end
      output
    end
    
  end
end
