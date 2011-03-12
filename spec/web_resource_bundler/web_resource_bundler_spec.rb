require File.expand_path(File.join(File.dirname(__FILE__), "../spec_helper"))
module WebResourceBundler
  describe Bundler do

    before(:each) do
      @s = settings
      @bundler = WebResourceBundler::Bundler
    end

    describe "#initialize" do 
      it "sets instance state correctly" do
        @bundler.logger.should == nil
      end
    end

    context "#bundler setup called" do
      before(:each) do
        @bundler.setup(root_dir, 'development')
      end

      describe "#filters_array" do
        it "returns array of filters that has :use => true in settings" do
          @bundler.set_settings(@s)
          filters = @bundler.send("filters_array", @bundler.filters)
          filters.size.should == 4
          @bundler.filters.size.should == 4
          i = 3
          %w{cdn_filter bundle_filter base64_filter compress_filter}.each do |s|
            @s[s.to_sym][:use] = false
            @bundler.set_settings(@s)
            filters = @bundler.send("filters_array", @bundler.filters)
            filters.size.should == i
            @bundler.filters.size.should == 4
            i -= 1
          end
        end
      end

      describe "#set_filters" do
        before(:each) do
          @file_manager = FileManager.new(@s)
          @bundler.instance_eval "@filters={}"
        end
        it "inits filters if no filters were initialized before" do
          @bundler.filters.should == {}
          @bundler.send("set_filters", @bundler.filters, @bundler.instance_variable_get("@file_manager"))
          #only 3 filters used by defaults
          @bundler.filters.size.should == 3
        end
        it "sets filters settings if filters already inited" do
          @bundler.send("set_filters", @bundler.filters, @bundler.instance_variable_get("@file_manager"))
          @bundler.filters[:base64_filter].settings[:max_image_size].should == @s[:base64_filter][:max_image_size]
          Settings.set({:base64_filter => {
                          :use => true, 
                          :max_image_size => 18
                        }})
          @bundler.send("set_filters", @bundler.filters, @bundler.instance_variable_get("@file_manager"))
          @bundler.filters[:base64_filter].settings[:max_image_size].should == 18 
        end
      end
      

      describe "#create_logger" do

        it "creates log directory if it's unexistent" do
          log_dir_path = File.dirname(Settings.settings[:log_path])
          FileUtils.rm_rf(log_dir_path)
          @bundler.send("create_logger", Settings.settings[:log_path])
          File.exist?(log_dir_path).should be_true
          FileUtils.rm_rf(log_dir_path)
        end

        it "sets log_path in settings if it isn't specified" do
          path = Settings.settings[:log_path] 
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
          block_data = @bundler.process(block_text, 'localhost:3000', 'http')
          files1 = BlockData.all_childs(block_data).inject([]) {|files, c| files += c.files.map {|f| f.path} }
          block_text = @sample_block_helper.sample_block
          block_data = @bundler.process(block_text, 'localhost:3000', 'http')
          files2 = BlockData.all_childs(block_data).inject([]) {|files, c| files += c.files.map {|f| f.path} }
          (files1.flatten - files2.flatten).should be_empty
        end
      end

      describe "#bundle_upto_date?" do
        it "returns true if block was already bundled and resulted files exist" do
          @bundler.set_settings(settings)
          clean_cache_dir
          block_text = @sample_block_helper.sample_block
          block_data = BlockParser.parse(block_text.dup)
          @bundler.send("bundle_upto_date?", block_data, @bundler.filters).should == false
          @bundler.process(block_text, 'localhost:3000', 'http')
          @bundler.send("bundle_upto_date?", block_data, @bundler.filters).should == true
        end
      end


      describe "#read_resources!" do
        it "populates block_data resource files structure with files content" do
          @bundler.set_settings(settings)
          block_data = @sample_block_helper.sample_block_data
          @bundler.send("read_resources!", block_data)
          all_files = block_data.all_files
          all_files.each do |file|
            CssUrlRewriter::rewrite_content_urls!(file.path, File.read(File.join(@s[:resource_dir], file.path))).should == file.content
          end
        end
      end

    end
  end
end
