module WebResourceBundler::RailsAppHelpers

  def web_resource_bundler_process(&block)
    #getting ActionView::NonConcattingString
    block_content = capture(&block)
    #but we want simple string to escape problems
    block_text = String.new(block_content)
    #we want to keep original string unchanged so we can return same content on error
    block_data = WebResourceBundler::Bundler.instance.process(block_text.dup)
    version = Rails::VERSION::STRING
    result = ""
    if block_data
      result = construct_block(block_data, WebResourceBundler::Bundler.instance.settings)  
    else
      result = block_text
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
    block_data.css.files.each_key do |name|
      url = File.join('/', settings.cache_dir, name)
      result += stylesheet_link_tag(url) 
      result += "\n"
    end
    block_data.js.files.each_key do |name|
      url = File.join('/', settings.cache_dir, name)
      result += javascript_include_tag(url) 
      result += "\n"
    end
    result += block_data.inline_block unless block_data.inline_block.blank?
    block_data.child_blocks.each do |block|
      result += construct_block(block, settings)
    end
    unless block_data.condition.empty?
      result = "<!--#{block_data.condition}>\n" + result + "<![endif]-->\n"
    end
    #removing unnecessary new line symbols
    result.gsub!(/\n(\s)+/, "\n")
    result
  end

end
