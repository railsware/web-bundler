module WebResourceBundler::RailsAppHelpers

  def web_resource_bundler_process(&block)
    #getting ActionView::NonConcattingString
    #but we want simple string to escape problems
    result = String.new(capture(&block))
    #result is original block content by default
    version = Rails::VERSION::STRING
    if !params['no_bundler'] and WebResourceBundler::Bundler.settings_correct
      #we want to keep original string unchanged so we can return same content on error
      block_data = WebResourceBundler::Bundler.process(result.dup, request.host_with_port, request.protocol.gsub(/:\/\//,''))
      #if everything ok with bundling we should construct resulted html content and change result
      result = construct_block(block_data, WebResourceBundler::Bundler.settings) if block_data 
    end
    case
      when version >= '3.0.0' then return raw(result) 
      when (version >= '2.2.0' and version < '2.4.0') then concat(result)
    else
      concat(result, block.binding)
    end
  end

  def construct_block(block_data, settings)
    result = ""
    #we should include only mhtml files if browser IE 7 or 6
    if mhtml_should_be_added?
      styles = block_data.files.select do |f| 
        !([WebResourceBundler::ResourceFileType::MHTML, WebResourceBundler::ResourceFileType::IE_CSS] & f.types).empty?
      end
    else
    #it normal browser - so just including base64 css
      styles = block_data.files.select {|f| f.types.include?(WebResourceBundler::ResourceFileType::CSS)}
    end
    styles.each do |file|
      url = File.join('/', file.path)
      result << stylesheet_link_tag(url) 
      result << "\n"
    end
    block_data.scripts.each do |file|
      url = File.join('/', file.path)
      result << javascript_include_tag(url) 
      result << "\n"
    end
    result << block_data.inline_block unless block_data.inline_block.blank?
    block_data.child_blocks.each do |block|
      result << construct_block(block, settings)
    end
    unless block_data.condition.empty?
      result = "<!--#{block_data.condition}>\n #{result}<![endif]-->\n"
    end
    #removing unnecessary new line symbols
    result.gsub!(/\n(\s)+/, "\n")
    result
  end

  def mhtml_should_be_added?
    result = false
    pattern = /MSIE (.*?);/
    header = request.headers['HTTP_USER_AGENT']
    match = pattern.match(header)
    if match and match[1] <= '7.0'  
        result = true
    end
    return result
  end

end
