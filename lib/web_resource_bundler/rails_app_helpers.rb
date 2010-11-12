module WebResourceBundler::RailsAppHelpers

  def process(&block)
    block_text = capture(&block)
    block_data = WebResourceBundler::Bundler.instance.process(block_text)
    result = ""
    if block_data
      result = construct_block(block_data, WebResourceBundler::Bundler.instance.settings)
    else
      result = block_text
    end
    version = Rails::version
    case
      when version >= '3.0.0' then return raw(result) 
      when (version >= '2.2.0' and version < '3.0.0') then concat(result)
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
    result += block_data.inline_block
    block_data.child_blocks.each do |block|
      result += construct_block(block, settings)
    end
    unless block_data.condition.empty?
      result = "<!--#{block_data.condition}>" + result + "<![endif]-->"
    end
    result
  end

end
