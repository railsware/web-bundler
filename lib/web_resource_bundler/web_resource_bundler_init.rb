require 'web_resource_bundler'
require 'yaml'
root_dir = Rails.root #or RAILS_ROOT if you are using older rails version than 3 
environment = Rails.env
settings = { }
settings_file_path = File.join(root_dir,'config', 'web_resource_bundler.yml')
if File.exist?(settings_file_path)
  settings_file = File.open(settings_file_path)
  all_settings = YAML::load(settings_file)
  if all_settings[environment]
    settings = all_settings[environment]
    settings[:resource_dir] = File.join(root_dir, 'public')
  end
end

WebResourceBundler::Bundler.instance.set_settings(settings)
ActionView::Base.send(:include, WebResourceBundler::RailsAppHelpers)
