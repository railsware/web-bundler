require File.expand_path(File.join(File.dirname(__FILE__), "../../spec_helper"))
describe WebResourceBundler::FileManager do

  def create_stub_file(name)
    File.open(File.join(@settings.resource_dir, name), "w") do |file|
      file.puts "hi there"
    end
  end

  before(:each) do
    temp_dir = File.join(@settings.resource_dir, 'temp')
    Dir.mkdir(temp_dir) unless File.exist?(temp_dir)
    @file1_url = 'temp/temp1.dat'
    @file1_path = File.join(@settings.resource_dir, @file1_url)
    create_stub_file(@file1_url)
    @file2_url = 'temp/temp2.dat'
    @file2_path = File.join(@settings.resource_dir, @file2_url)
    create_stub_file(@file2_url) 
    sleep 1
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
  
  describe "#bundle_upto_date?" do

    def is_upto_date?
      @manager.bundle_upto_date?(@bundle_url, [@file1_url, @file2_url])
    end

    context "bundle file exist" do

      it "returns true if bundle last access time greater than for resource files" do
        is_upto_date?.should be_true
      end

      it "returns false if one of files was modified after bundling" do
        sleep 1
        system("touch -m #{@file1_path}" )
        is_upto_date?.should be_false 
      end

    end

    context "bundle file doesn't exists" do
      it "returns false" do
        File.delete(@bundle_path)
        is_upto_date?.should == false
      end
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
