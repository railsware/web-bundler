require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::Filters::CdnFilter do
  before(:each) do
    @settings = settings
    @cdn_settings = cdn_settings
    @cdn_settings[:http_hosts] = ['http://boogle.com']
    @cdn_settings[:https_hosts] = ['http://froogle.com']
    @settings[:cdn_filter][:http_hosts] = @cdn_settings[:http_hosts] 
    @settings[:cdn_filter][:https_hosts] = @cdn_settings[:https_hosts]
    @file_manager = FileManager.new(@settings[:resource_dir], @settings[:cache_dir]) 
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
      @filter.new_filepath(path).should == 'cache/cdn_1.css'
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
      file = WebResourceBundler::ResourceFile.new_css_file('/temp.css', "background: url('./images/1.png');background-image: url('./images/1.png');")
      block_data = BlockData.new
      block_data.files = [file]
      @filter.apply!(block_data)
      block_data.files.first.path.should == File.join(@settings[:cache_dir], 'cdn_temp.css')
      block_data.files.first.content.should == "background: url('http://boogle.com/images/1.png');background-image: url('http://boogle.com/images/1.png');"
    end
  end

end
