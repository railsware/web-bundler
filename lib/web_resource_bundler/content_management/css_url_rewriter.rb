class WebResourceBundler::CssUrlRewriter
  class << self
		URL_TAG_PATTERN = /url\s*\(['|"]?([^\)'"]+)['|"]?\)/i
    # rewrites a relative path to an absolute path, removing excess "../" and "./"
    # rewrite_relative_path("stylesheets/default/global.css", "../image.gif") => "/stylesheets/image.gif"
    def rewrite_relative_path(source_url, relative_url)
      return relative_url if URI.parse(relative_url).absolute?
      File.expand_path(relative_url, File.dirname(source_url))
    end
  
    # rewrite the URL reference paths
    # url(../../../images/active_scaffold/default/add.gif);
    # url(/stylesheets/active_scaffold/default/../../../images/active_scaffold/default/add.gif);
    # url(/stylesheets/active_scaffold/../../images/active_scaffold/default/add.gif);
    # url(/stylesheets/../images/active_scaffold/default/add.gif);
    # url('/images/active_scaffold/default/add.gif');
    def rewrite_content_urls!(filename, content)
      content.gsub!(URL_TAG_PATTERN) { "url('#{rewrite_relative_path(filename, $1)}')" }
      content
    end

  end
end 
