WebResourceBundler::Bundler.instance.setup(Rails.root, Rails.env)
ActionView::Base.send(:include, WebResourceBundler::RailsAppHelpers)

