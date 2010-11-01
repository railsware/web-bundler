require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))
describe WebResourceBundler::FilterBase do
  describe "#apply" do
    context "exception raised during block invocation" do
      before(:each) do
        @logger = mock('logger')
        @error_text = "Error text"
        @exception = Exception.new(@error_text)
      end
      
      it "logs error" do
        @logger.should_receive(:error).with("WebResourceBundler::FilterBase: #{@error_text}")
        FilterBase.new(@settings, @logger).apply() { raise @exception }
      end

      context "clenaup called" do
        before(:each) do
          @cleaner = mock('cleaner')
          @cleaner.should_receive(:clean)
        end

        class FilterChild < FilterBase
          def initialize(cleaner, settings, logger, exception)
            super settings, logger
            @cleaner = cleaner
            @exception = exception
          end
          def apply
            super do
              raise @exception 
            end
          end
        end
        it "invokes clean method of child object" do
          class FilterChild < FilterBase
            def cleanup
              @cleaner.clean
            end
          end
          f = FilterChild.new(@cleaner, @settings, @logger, @exception)
          @logger.should_receive(:error).with("#{f.class}: #{@error_text}")
          f.apply
        end
        it "invokes clean method of child object" do
          class FilterChild < FilterBase
            def cleanup
              @cleaner.clean
              raise @exception
            end
          end
          f = FilterChild.new(@cleaner, @settings, @logger, @exception)
          @logger.should_receive(:error).with("#{f.class}: #{@error_text}")
          @logger.should_receive(:error).with("#{f.class}: cleanup failed") 
          f.apply
        end
      end

    end

  end
end

