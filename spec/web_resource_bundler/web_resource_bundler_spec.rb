require File.join(File.dirname(__FILE__), "../spec_helper")
module WebResourceBundler
  describe Bundler do
    describe "#process" do
      it "process block" do
        bundler = Bundler.new(@@settings)
        bundler.process sample_block
      end
    end
  end
end
