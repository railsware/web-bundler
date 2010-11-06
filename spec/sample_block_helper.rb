class SampleBlockHelper
  def initialize(styles, scripts, settings)
    @styles = styles
    @scripts = scripts
    @settings = settings
  end
  
  def construct_js_link(path)
    "<script src = \"#{path}\" type=\"text/javascript\"></script>"
  end

  def construct_css_link(path)
    "<link href = \"#{path}\" media=\"screen\" rel=\"Stylesheet\" type=\"text/css\" />"
  end

  def sample_inline_block
    "this is inline block content" +
        "<script>abracadabra</script><style>abracadabra</style>"
  end

  def construct_links_block(styles, scripts)
    block = ""
    styles.each do |path|
      block += construct_css_link(path)
    end
    scripts.each do |path|
      block += construct_js_link(path)
    end
    block
  end

  def construct_resource_bundle(type, files)
    files_hash = {}
    files.each do |file|
      content = File.read(File.join(@settings.resource_dir, file))
      files_hash[file] = content
    end
    ResourceBundle::Data.new(type, files_hash)
  end

  def sample_cond_block
    "<!-- [if IE 7] >" +
    construct_links_block(@styles[(@styles.size / 2)..-1], @scripts[(@styles.size / 2)..-1]) +
    sample_inline_block +
    "<! [endif] -->"
  end

  def sample_block
    block = construct_links_block(@styles[0..(@styles.size / 2 - 1)], @scripts[0..(@styles.size / 2 - 1)]) + "\n"
    block += sample_inline_block
    block += sample_cond_block
  end

  def sample_block_data
    data = BlockData.new
    data.css = construct_resource_bundle(ResourceBundle::CSS, @styles[0..(@styles.size / 2)])
    data.js = construct_resource_bundle(ResourceBundle::JS, @scripts[0..(@styles.size / 2)])
    data.inline_block = sample_inline_block
    data.child_blocks << child_block_data
    data
  end

  def child_block_data
    child = BlockData.new("[if IE 7]")
    child.css = construct_resource_bundle(ResourceBundle::CSS, @styles)
    child.js = construct_resource_bundle(ResourceBundle::JS, @scripts)
    child.inline_block = sample_inline_block
    child
  end

end


def clean_public_folder
  FileUtils.rm_rf(File.join(@settings.resource_dir,'/*'))
end
