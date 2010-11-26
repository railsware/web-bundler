require 'web_resource_bundler'
settings = {
  :resource_dir => File.join(Rails.root, 'public'),
  :log_path => File.join(Rails.root, 'log/web_resource_bundler.log'),
  :cache_dir => 'cache',
  :base64_filter => {
    :max_image_size => 30, #kbytes
    :protocol => 'http',
    :domain => 'localhost:3000'
  },
  :bundle_filter => {
    :md5_additional_data => []
  },
  :cdn_filter => {
    :http_hosts => ['http://localhost:3000'],
    :https_hosts => ['https://localhost:3000']
  }
}
WebResourceBundler::Bundler.new(settings)
ActionView::Base.send(:include, WebResourceBundler::RailsAppHelpers)
