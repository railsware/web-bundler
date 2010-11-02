require File.expand_path(File.join(File.dirname(__FILE__), "../../../spec_helper"))
describe WebResourceBundler::Filters::BundleFilter::Filter do
  before(:each) do
    clean_cache_dir
    @filter = Filters::BundleFilter::Filter.new(@settings, @logger)
  end

  describe "#cleanup" do
    it "deletes bundle css and js files" do
      filter = Filters::BundleFilter::Filter.new(@settings, @logger)
      css_bundle = 'bundle_mock_css.css'
      js_bundle = 'bundle_mock_js.js'
      create_mock_file(css_bundle)
      create_mock_file(js_bundle)
      File.exist?(File.join(@settings.resource_dir, css_bundle)).should be_true
      File.exist?(File.join(@settings.resource_dir, js_bundle)).should be_true
      filter.instance_eval "@css_bundle = '#{css_bundle}'; @js_bundle = '#{js_bundle}'"
      filter.cleanup
      File.exist?(File.join(@settings.resource_dir, css_bundle)).should be_false
      File.exist?(File.join(@settings.resource_dir, js_bundle)).should be_false
    end
  end

  it "creates cache 2 on initialization" do
    File.exist?(File.join(@settings.resource_dir, @settings.cache_dir)).should be_true
  end

  describe "#apply" do
    it "bundles each block_data resources in single file" do
      block_data = @sample_block_helper.sample_block_data
      @filter.apply(block_data)
      File.exist?(File.join(@settings.resource_dir, @settings.cache_dir, block_data.css.bundle_filename(@settings))).should be_true
      File.exist?(File.join(@settings.resource_dir, @settings.cache_dir, block_data.js.bundle_filename(@settings))).should be_true
    end
  end
end

