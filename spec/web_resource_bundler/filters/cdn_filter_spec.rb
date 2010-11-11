require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::Filters::CdnFilter do
  before(:each) do
    @cdn_settings[:http_hosts] = ['http://boogle.com']
    @file_manager = FileManager.new @settings
    @filter = Filters::CdnFilter::Filter.new(@cdn_settings, @file_manager)
  end

  describe "#host_for_image" do
    it "returns host for image using its hash" do
     @cdn_settings[:http_hosts] << 'http://froogle.com'
     url = '/images/1.gif'
     @filter.host_for_image(url).should == @cdn_settings[:http_hosts][url.hash % @cdn_settings[:http_hosts].size]
    end

    it "returns https host if request was https" do
      @cdn_settings[:protocol] = 'https'
      @filter = Filters::CdnFilter::Filter.new(@cdn_settings, @file_manager)
      url = '/images/1.gif'
      @filter.host_for_image(url).should == @cdn_settings[:https_hosts][url.hash % @cdn_settings[:https_hosts].size]
    end
  end

  describe "#new_filename" do
    it "adds cdn_ prefix to original file name" do
      path = 'styles/1.css'
      @filter.new_filename(path).should == 'cdn_1.css'
    end
  end

  describe "#rewrite_content_urls!" do
    before(:each) do
      @file_path = '/styles/skin/1.css'
    end

    it "adds hosts to image urls" do
      content = "background: url('../images/1.png');"
      @filter.rewrite_content_urls!(@file_path, content)
      content.should == "background: url('http://boogle.com/styles/images/1.png');"
    end

    it "doesn't add hosts for images encoded in base64" do
      content = "background:url('data:image/png;base64,iVBORw0KGg); *background:url(mhtml:http://domain.com/cache/base64_ie_style_9648c01be7e50284958eb07877c70e03.en.css!rails5804) no-repeat 0 100%;"
      clon = content.dup
      @filter.rewrite_content_urls!(@file_path, content.dup)
      content.should == clon 
    end

    it "binds image to one particular host" do
      @cdn_settings[:http_hosts] << 'http://froogle.com'
      @filter = Filters::CdnFilter::Filter.new(@cdn_settings, @file_manager)
      content = "background: url('../images/1.png');background-image: url('../images/1.png');" 
      host = @cdn_settings[:http_hosts]['/styles/images/1.png'.hash % @cdn_settings[:http_hosts].size]
      url = "#{host}/styles/images/1.png"
      @filter.rewrite_content_urls!(@file_path, content)
      content.should == "background: url('#{url}');background-image: url('#{url}');"
    end
  end

  describe "#apply" do
    it "rewrites urls properly in all css file of given block_data" do
      resource = @sample_block_helper.construct_resource_bundle(ResourceBundle::CSS, [])
      resource.files = {'/temp.css' => "background: url('./images/1.png');background-image: url('./images/1.png');"}
      block_data = BlockData.new
      block_data.css = resource
      @filter.apply(block_data)
      block_data.css.files['cdn_temp.css'].should == "background: url('http://boogle.com/images/1.png');background-image: url('http://boogle.com/images/1.png');"
    end
  end

  describe "#change_resulted_files!" do
    it "returns hash with modified css files paths" do
      block_data = @sample_block_helper.sample_block_data
      block_data.css.files = {'styles/1.css' => "", '/4.css' => ""}
      block_data.js.files = {'file/that/shouldnt/change.js' => ""}
      block_data.condition = ""
      @filter.change_resulted_files!(block_data) 
      block_data.css.files.keys.sort.should == ['cdn_1.css', 'cdn_4.css'].sort
      block_data.js.files.keys.should == ['file/that/shouldnt/change.js']
    end
  end

end
