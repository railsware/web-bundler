require File.expand_path(File.join(File.dirname(__FILE__), "../spec_helper"))
describe WebResourceBundler::FileManager do
  before(:each) do
    @settings = settings
  end

  def create_stub_file(name)
    File.open(File.join(@settings.resource_dir, name), "w") do |file|
      file.print "hi there"
    end
  end

  before(:each) do
    temp_dir = File.join(@settings.resource_dir, 'temp')
    Dir.mkdir(temp_dir) unless File.exist?(temp_dir)
    @bundle_url = 'temp/bundle.dat'
    @bundle_path = File.join(@settings.resource_dir, @bundle_url)
    create_stub_file(@bundle_url)
    @manager = FileManager.new @settings
  end

  after(:each) do
    FileUtils.rm_rf(File.join(@settings.resource_dir, 'temp'))
  end

  describe "#create_cache_dir" do
    it "creates cache dir if it doesn't exists" do
      dir_path = File.join(@settings.resource_dir, @settings.cache_dir)
      FileUtils.rm_rf(dir_path)
      @manager.create_cache_dir
      File.exist?(dir_path).should == true
    end
  end

  describe "#get_content" do
    it "reads file and returns its content" do
      @manager.get_content(@bundle_url).should == 'hi there'
    end
  end

  describe "#full_path" do

    it "returns full path using file url" do
      @manager.full_path(@bundle_url).should == @bundle_path 
    end

  end

  describe "#exist?" do

    it "returns false when no such file in resource dir" do
      @manager.exist?("non_existent_file.data").should == false
    end

    it "return true when file exists in resource dir" do
      @manager.exist?(@bundle_url).should == true
    end
  end

end
