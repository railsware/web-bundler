module WebResourceBundler::Filters::BundleFilter
  class ResourcePackager
    IMPORT_PTR = /\@import ['|"](.*?)['|"];/i

    def initialize(settings, file_manager)
      @settings     = settings
      @file_manager = file_manager 
    end

    #recursively iterates through all files and imported files
    def bundle_files(files)
      output = ""
      files.select { |f| !f.content.empty? }.each do |file|
        content = file.content
        path    = file.path
        output  << bundled_file_header(path) 
        output  << include_imported_files(content, path) if file.type[:ext] == 'css'
        content << javascript_fix                        if file.type[:ext] == '.js' 
        output  << content
        output  << bundled_file_footer(path)
      end
      output
    end

    private

    #to avoid problems with javascript we should add closing ;
    def javascript_fix
      ';' 
    end

    def include_imported_files(content, base_path)
      imported_file_paths     = extract_imported_files!(content, base_path)
      imported_resource_files = build_imported_files(imported_file_paths) 
      imported_resource_files.any? ? bundle_files(imported_resource_files) : ''
    end
  
    #finds all imported files paths in css
    def extract_imported_files!(content, base_file_path)
      paths = []
      content.gsub!(IMPORT_PTR) do |result|
        path  = $1 
        paths << File.join(File.dirname(base_file_path), path) if path 
        ""
      end
      paths
    end

    def bundled_file_header(path)
      "/* --------- #{path} --------- */\n"
    end

    def bundled_file_footer(path)
      "\n/* --------- END #{path} --------- */\n"
    end

    #created resource files using imported files paths
    def build_imported_files(imported_file_paths) 
      files = []
      imported_file_paths.map do |path|
        files << WebResourceBundler::ResourceFile.new_css_file(path, @file_manager.get_content(path)) if File.basename(path).split('.')[-1] == 'css'
      end
      files
    end

  end
end
