require 'web_resource_bundler'
require 'yaml'
root_dir = Rails.root #or RAILS_ROOT if you are using older rails version than 3 
environment = Rails.env
settings = { }


WebResourceBundler::Bundler.instance.set_settings(settings)
ActionView::Base.send(:include, WebResourceBundler::RailsAppHelpers)
