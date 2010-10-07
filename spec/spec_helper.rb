$:.unshift(File.join(File.dirname(__FILE__), "../lib"))
require 'web_resource_packager'
module WebResourcePackager
  @@styles = ["/styles/foo.css","/styles/sample.css", "/styles/temp.css", "/sample.css"]
  @@scripts = ["/scripts/13.js", "/scripts/my_script.js", "/foo/boo.js", "/goo/doo.js"]
  @@files1 = BlockFiles.new(@@scripts[0..1],@@styles[0..1])
  @@files2 = BlockFiles.new(@@scripts[2..3],@@styles[2..3])
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
    data.files = @@files1
    data.inline_block = sample_inline_block
    data.child_blocks << child_block_data1
    data
  end

  def child_block_data1
    child = BlockData.new(@@condition)
    child.files = @@files2
    child.inline_block = sample_inline_block
    child
  end

  def child_block_data2
    child = BlockData.new(@@condition2)
    child.files = @@files1
    child.inline_block = sample_inline_block
    child
  end

  @@settings_hash = {
      :domen => "google.com",
      :language => "eng"
    }

end
