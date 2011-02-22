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
      files.select{|f| not f.content.empty? }.each do |file|
        path = file.path
        content = file.content
        output << "/* --------- #{path} --------- */\n"
        if file.type[:ext] == 'css'
          imported_files = extract_imported_files!(content, path)
          #getting imported (@import ...) files contents
          imported_resource_files = [] 
          imported_files.each do |imported_file|
            imported_resource_files << WebResourceBundler::ResourceFile.new_css_file(imported_file, @file_manager.get_content(imported_file))
          end
          #bundling imported files
          output << bundle_files(imported_resource_files) unless imported_resource_files.empty?
        end
        #adding ';' symbol in case javascript developer forget to do this
        content << ';' if File.extname(path) == '.js'
        output << content
        output << "\n/* --------- END #{path} --------- */\n"
      end
      output
    end

    #finds all imported files in css
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
