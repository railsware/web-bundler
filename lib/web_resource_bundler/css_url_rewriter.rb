class WebResourceBundler::CssUrlRewriter
  class << self
    # rewrites a relative path to an absolute path, removing excess "../" and "./"
    # rewrite_relative_path("stylesheets/default/global.css", "../image.gif") => "/stylesheets/image.gif"

    def rewrite_relative_path(source_url, relative_url)
      #if its full web link should be returned as is
      return relative_url if relative_url.include?("://")
      #creating dir list without filename that is the last element
      result = source_url.split('/')[0..-2]
      elements = relative_url.split('/')
      #iterating through all dir elements of relative url
      #constructing result - final resource path
      elements[0..-2].each do |e|
        if e == '..'
          result.pop
        else
          result.push e unless e == '.'
        end
      end
      #adding file name - last element of elememnts
      result << elements[-1]
      #removing empty elements
      result.delete('')
      '/' + result.join('/')
    end
  
    # rewrite the URL reference paths
    # url(../../../images/active_scaffold/default/add.gif);
    # url(/stylesheets/active_scaffold/default/../../../images/active_scaffold/default/add.gif);
    # url(/stylesheets/active_scaffold/../../images/active_scaffold/default/add.gif);
    # url(/stylesheets/../images/active_scaffold/default/add.gif);
    # url('/images/active_scaffold/default/add.gif');
    def rewrite_content_urls(filename, content)
      content.gsub!(/url\s*\(['|"]?([^\)'"]+)['|"]?\)/) { "url('#{rewrite_relative_path(filename, $1)}')" }
      content
    end
    
  end
end 
