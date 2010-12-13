require File.expand_path(File.join(File.dirname(__FILE__), "../spec_helper"))
module WebResourceBundler
  describe Bundler do

    before(:each) do
      @s = settings
      @bundler = WebResourceBundler::Bundler.instance
    end

    describe "#set_settings" do
      it "sets settings_correct property to false if resource dir not specified" do
        @bundler.set_settings({})
        @bundler.settings_correct.should be_false
      end
      it "sets settings_correct property to true if resource dir specified" do
        @bundler.set_settings({:resource_dir => @s[:resource_dir]})
        @bundler.settings_correct.should be_true
      end
    end


    describe "#filters_array" do
      it "returns array of filters that has :use => true in settings" do
        @bundler.set_settings(@s)
        filters = @bundler.send("filters_array")
        filters.size.should == 3
        @bundler.filters.size.should == 3
        i = 2
        %w{cdn_filter bundle_filter base64_filter}.each do |s|
          @s[s.to_sym][:use] = false
          @bundler.set_settings(@s)
          filters = @bundler.send("filters_array")
          filters.size.should == i
          @bundler.filters.size.should == 3
          i -= 1
        end
      end
    end

    describe "#set_filters" do
      before(:each) do
        @file_manager = FileManager.new(@s[:resource_dir], @s[:cache_dir])
        @bundler.instance_eval "@filters={}"
      end
      it "inits filters if no filters were initialized before" do
        @bundler.filters.should == {}
        @bundler.send("set_filters", @s, @file_manager)
        @bundler.filters.size.should == 3
      end
      it "sets filters settings if filters already inited" do
        @bundler.send("set_filters", @s, @file_manager)
        @bundler.filters[:base64_filter].settings[:max_image_size].should == @s[:base64_filter][:max_image_size]
        @s[:base64_filter][:max_image_size] = 90
        @bundler.send("set_filters", @s, @file_manager)
        @bundler.filters[:base64_filter].settings[:max_image_size].should == 90 
      end
    end
    describe "#initialize" do 
      it "set instance to nil if resource_dir ins't specified" do 
        @bundler.set_settings({})
        @bundler.settings_correct.should be_false
      end
      it "correctly inits cache dir, and log path with defaults if resource_dir specified" do
        res_dir = settings[:resource_dir]
        @bundler.set_settings({:resource_dir => res_dir })
        @bundler.settings_correct.should be_true
        @bundler.settings[:cache_dir].should == 'cache'
        @bundler.settings[:log_path].should == File.expand_path('../log/web_resource_bundler.log', res_dir)
      end
      it "creates log directory if it's unexistent" do
        @bundler.set_settings({:resource_dir => @s[:resource_dir]})
        log_dir_path = File.expand_path('../log', @s[:resource_dir])
        File.exist?(log_dir_path).should be_true
        Dir.delete(log_dir_path)
      end
    end

    describe "#create_logger" do
      it "sets log_path in settings if it isn't specified" do
        path = File.expand_path('../web_resource_bundler.log', @s[:resource_dir])
        @bundler.send("create_logger", path)
        File.exist?(path).should be_true
        File.delete(path)
      end
    end

    describe "#process" do
      it "returns the same filenames when bundling or just computing resulted files" do
        @bundler.set_settings(settings)
        clean_cache_dir
        block_text = @sample_block_helper.sample_block
        block_data = @bundler.process(block_text)
        files1 = BlockData.all_childs(block_data).inject([]) {|files, c| files += c.files.map {|f| f.path} }
        block_text = @sample_block_helper.sample_block
        block_data = @bundler.process(block_text)
        files2 = BlockData.all_childs(block_data).inject([]) {|files, c| files += c.files.map {|f| f.path} }
        (files1.flatten - files2.flatten).should be_empty
      end
    end

    describe "#bundle_upto_date?" do
      it "returns true if block was already bundled and resulted files exist" do
        @bundler.set_settings(settings)
        clean_cache_dir
        block_text = @sample_block_helper.sample_block
        block_data = BlockParser.new.parse(block_text.dup)
        @bundler.send("bundle_upto_date?", block_data).should == false
        @bundler.process(block_text)
        @bundler.send("bundle_upto_date?", block_data).should == true
      end
    end


    describe "#read_resources!" do
      it "populates block_data resource files structure with files content" do
        @bundler.set_settings(settings)
        block_data = @sample_block_helper.sample_block_data
        @bundler.send("read_resources!", block_data)
        all_files = block_data.styles + block_data.scripts + block_data.child_blocks[0].styles + block_data.child_blocks[0].scripts
        all_files.each do |file|
          CssUrlRewriter::rewrite_content_urls!(file.path, File.read(File.join(@s[:resource_dir], file.path))).should == file.content
        end
      end
    end

  end
end
