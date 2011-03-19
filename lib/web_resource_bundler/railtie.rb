require 'rails'

module WebResourceBundler
  class Railtie < Rails::Railtie
    initializer "web_resource_bundler_initializer.configure_rails_initialization" do
      WebResourceBundler::Bundler.setup(Rails.root, Rails.env)
      ActionView::Base.send(:include, WebResourceBundler::RailsAppHelpers)
    end
  end
end
