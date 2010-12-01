require 'web_resource_bundler'
require 'yaml'
root_dir = Rails.root #or RAILS_ROOT if you are using older rails version than 3 
environment = Rails.env
settings = {
  :resource_dir => File.join(root_dir, 'public'),
  :base64_filter => {
    :use => true,
    :max_image_size => 23, #kbytes
    :protocol => 'http',
    :domain => 'localhost:3000'
  },
  :bundle_filter => {
    :use => true,
    :md5_additional_data => []
  },
  :cdn_filter => {
    :use => true,
    :http_hosts => ['http://localhost:3000'],
    :https_hosts => ['https://localhost:3000']
  }
}
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
