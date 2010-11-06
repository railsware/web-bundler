require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::Filters::CdnFilter do
  before(:each) do
    @settings.http_hosts = ['http://boogle.com']
    @file_manager = FileManager.new @settings
    @filter = Filters::CdnFilter::Filter.new(@settings, @file_manager)
  end

  describe "#host_for_image" do
    it "returns host for image using its hash" do
     @settings.http_hosts << 'http://froogle.com'
     url = '/images/1.gif'
     @filter.host_for_image(url).should == @settings.http_hosts[url.hash % @settings.http_hosts.size]
    end

    it "returns https host if request was https" do
      @settings.protocol = 'https'
      @filter = Filters::CdnFilter::Filter.new(@settings, @file_manager)
      url = '/images/1.gif'
      @filter.host_for_image(url).should == @settings.https_hosts[url.hash % @settings.https_hosts.size]
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

    it "binds image to one particular host" do
      @settings.http_hosts << 'http://froogle.com'
      @filter = Filters::CdnFilter::Filter.new(@settings, @file_manager)
      content = "background: url('../images/1.png');background-image: url('../images/1.png');" 
      host = @settings.http_hosts['/styles/images/1.png'.hash % @settings.http_hosts.size]
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
      block_data.css.files['/cdn_temp.css'].should == "background: url('http://boogle.com/images/1.png');background-image: url('http://boogle.com/images/1.png');"
    end
  end

end
