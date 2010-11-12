module WebResourceBundler::Filters::BundleFilter
  class ResourcePackager
    IMPORT_PTR = /\@import ['|"](.*?)['|"];/

    def initialize(settings, file_manager)
      @settings = settings
      @file_manager = file_manager 
    end

    #recursively iterates through all files and imported files
    def bundle_files(files)
      output = ""
      files.each_pair do |path, content|
        output << "/* --------- #{path} --------- */\n"
        if File.extname(path) == '.css'
          imported_files = extract_imported_files!(content, path)
          #getting imported files contents
          imported_files_hash = {}
          imported_files.each do |file|
            imported_files_hash[file] = @file_manager.get_content(file)
          end
          #bundling imported files
          output << bundle_files(imported_files_hash) unless imported_files_hash.empty?
        end
        content += ';' if File.extname(path) == '.js'
        output << content
        output << "/* --------- END #{path} --------- */\n"
      end
      output
    end

    def extract_imported_files!(content, base_file_path)
      imported_files = []
      content.gsub!(IMPORT_PTR) do |result|
        imported_file = IMPORT_PTR.match(result)[1]
        if imported_file
          imported_files << File.join(File.dirname(base_file_path), imported_file)
        end
        result = ""
      end
      return imported_files
    end

  end
end
