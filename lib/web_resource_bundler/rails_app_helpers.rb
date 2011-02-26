module WebResourceBundler::RailsAppHelpers

  DATA_URI_START = "<!--[if (!IE)|(gte IE 8)]><!-->" 
  DATA_URI_END   = "<!--<![endif]-->"               
  MHTML_START    = "<!--[if lte IE 7]>"             
  MHTML_END      = "<![endif]-->"                    

  def web_resource_bundler_process(&block)
    #getting ActionView::NonConcattingString
    #but we want simple string to escape problems
    result = String.new(capture(&block))
    if !params['no_bundler'] && WebResourceBundler::Settings.correct?
      #we want to keep original string unchanged so we can return same content on error
      block_data = WebResourceBundler::Bundler.process(result.dup, request.host_with_port, request.protocol.gsub(/:\/\//,''))
      #if everything ok with bundling we should construct resulted html content and change result
      result = construct_block(block_data, WebResourceBundler::Settings.settings) if block_data 
    end
		construct_result(Rails::VERSION::STRING, result, block)
  end

  def construct_block(block_data, settings)
		result = ""
		result << data_uri_part(block_data.base64_styles) 
		result <<		 mhtml_part(block_data.mhtml_styles) 
		result <<	 scripts_part(block_data.scripts) 

    result << block_data.inline_block unless block_data.inline_block.blank?

    block_data.child_blocks.each do |block|
      result << construct_block(block, settings)
    end

    unless block_data.condition.empty?
      result = "<!--#{block_data.condition}>\n#{result}<![endif]-->\n"
    end

    #removing unnecessary new line symbols
    result.gsub!(/\n(\s)+/, "\n")
    result
  end

  private

	#constructs resulted html text
	#method depends on rails version
	def construct_result(version, result, block)
		case
      when version >= '3.0.0'                      then raw(result) 
      when version >= '2.2.0' && version < '2.4.0' then concat(result) 
    else
      concat(result, block.binding)
    end
	end

	def data_uri_part(styles)
		result = DATA_URI_START + "\n" 
    styles.inject(result) do |data, file|
      data << construct_file_link(file.path)
    end
    result << DATA_URI_END << "\n"
	end

	def mhtml_part(styles)
		result = MHTML_START + "\n"
    styles.inject(result) do |data, file|
      data << construct_file_link(file.path)
    end
    result << MHTML_END + "\n"
	end

	def scripts_part(scripts)
		scripts.inject("") do |data, file|
			url  =  File.join('/', file.path)
			data << javascript_include_tag(url) << "\n"
		end
	end

  def construct_file_link(path)
    url = File.join('/', path)
    stylesheet_link_tag(url) << "\n"
  end

end
