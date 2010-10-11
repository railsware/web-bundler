$:.unshift(File.join(File.dirname(__FILE__), "../lib"))
require 'web_resource_packager'
module WebResourcePackager

  @@settings_hash = {
      :domen => "google.com",
      :language => "en",
      :encode_images? => true,
      :max_image_size => 30,
      :resource_dir => File.join(File.dirname(__FILE__), '/public'),
      :cache_dir => '/cache'
    }

  @@settings = Settings.new @@settings_hash

  @@styles = ["/sample.css","/foo.css", "/temp.css", "/boo.css"]
  @@scripts = ["/set_cookies.js", "/seal.js", "/salog20.js", "/marketing.js"]
  @@res1 = ResourceBundle::Data.new(ResourceBundle::CSS, @@styles[0..1])
  @@res2 = ResourceBundle::Data.new(ResourceBundle::JS, @@scripts[0..1])
  @@res3 = ResourceBundle::Data.new(ResourceBundle::CSS, @@styles[2..3])
  @@res4 = ResourceBundle::Data.new(ResourceBundle::JS, @@scripts[2..3])

  @@condition = "[if IE 7]"
  @@condition2 = "[if IE 6]"

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

  def sample_cond_block
    "<!-- [if IE 7] >" +
    construct_links_block(@@styles[2..3], @@scripts[2..3]) +
    sample_inline_block +
    "<! [endif] -->"
  end

  def sample_block
    block = construct_links_block(@@styles[0..1], @@scripts[0..1]) + "\n"
    block += sample_inline_block
    block += sample_cond_block
  end

  def sample_block_data
    data = BlockData.new
    data.css = @@res1
    data.js = @@res2
    data.inline_block = sample_inline_block
    data.child_blocks << child_block_data1
    data
  end

  def child_block_data1
    child = BlockData.new(@@condition)
    child.css = @@res3
    child.js = @@res4
    child.inline_block = sample_inline_block
    child
  end

  def child_block_data2
    child = BlockData.new(@@condition2)
    child.css = @@res1
    child.js = @@res2
    child.inline_block = sample_inline_block
    child
  end

  
end
