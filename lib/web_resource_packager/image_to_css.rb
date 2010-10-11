$:.unshift File.dirname(__FILE__)
require 'image_to_css/image_data'
require 'base64'
require 'image_to_css/css_file_generator'
require 'find'
module WebResourcePackager::ImageToCss
  def self.convert_all_css(folder, host)
    if Dir.exist?(folder)
      all_css_files = Find.find(folder).find_all do |f|
        !CssFileGenerator.already_encoded?(f) and File.extname(f) == ".css"
      end
      all_css_files.each do |f|
        CssFileGenerator.generate(File.absolute_path(f), host)
      end
    end
  end

  def self.find_css_links_in_html(filename)
    if File.exist?(filename)
      head_section = ""
      section_read = false
      File.open(filename, "r") do |f|
        while line = f.gets and !section_read
          if line =~ /<head>/
            while line =~ /<head>/ .. line =~ /<\/head>/ do
              head_section += line
              line = f.gets
            end
            section_read = true
          end
        end
      end
      return head_section
    else
      return nil
    end
  end
end
