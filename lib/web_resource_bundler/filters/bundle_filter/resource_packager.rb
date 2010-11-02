module WebResourceBundler
  module Filters
    module BundleFilter
      class ResourcePackager
        IMPORT_PTR = /\@import ['|"](.*?)['|"];/

        def initialize(settings)
          @settings = settings
          @file_manager = WebResourceBundler::FileManager.new @settings
          path = File.join(@settings.resource_dir, @settings.cache_dir)
          unless File.exist?(path)
            Dir.mkdir(path)
          end
        end

        def bundle_resource(data)
          unless data.files.empty?
            bundle_url = File.join(@settings.cache_dir, data.bundle_filename(@settings)) 
            path = @file_manager.full_path(bundle_url)
            content = bundle_files(data.files)
            if content and not @file_manager.bundle_upto_date?(bundle_url, data.files)
              File.open(path, "w") do |file|
                file.puts content
              end
            end
            return bundle_url 
          end
        end

        #recursively iterates through all files and imported files
        def bundle_files(urls = [])
          output = ""
          urls.each do |url|
            output << "/* --------- #{url} --------- */\n"
            file_path = @file_manager.full_path(url)
            raise Exceptions::ResourceNotFoundError.new(file_path) unless @file_manager.exist?(url)
            content = File.read(file_path)
            imported_files = extract_imported_files!(content).map {|f| File.join(File.dirname(url), f)}
            output << bundle_files(imported_files)
            content = WebResourceBundler::CssUrlRewriter.rewrite_content_urls(url, content) if File.extname(file_path) == '.css' 
            output << content
            output << "/* --------- END #{url} --------- */\n"
          end
          output
        end

        def extract_imported_files!(content)
          imported_files = []
          content.gsub!(IMPORT_PTR) do |result|
            imported_file = IMPORT_PTR.match(result)[1]
            if imported_file
              imported_files << imported_file
            end
            result = ""
          end
          return imported_files
        end

      end
    end
  end
end
