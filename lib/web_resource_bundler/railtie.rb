require 'rails'

class WebResourceBundler::Railtie < Rails::Railtie
  WebResourceBundler::Bundler.setup(Rails.root, Rails.env)
  ActionView::Base.send(:include, WebResourceBundler::RailsAppHelpers)
end