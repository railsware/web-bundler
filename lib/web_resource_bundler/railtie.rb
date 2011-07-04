module WebResourceBundler

  if defined?(Rails::Railtie)
    require 'rails'
    class Railtie < Rails::Railtie
      initializer "web_resource_bundler_initializer.configure_rails_initialization" do
        ActiveSupport.on_load :action_view do
          WebResourceBundler::Railtie.insert
        end
      end
    end
  end

  class Railtie
    def self.insert
      WebResourceBundler::Bundler.setup(Rails.root, Rails.env)
      ActionView::Base.send(:include, WebResourceBundler::RailsAppHelpers)
    end
  end

end
