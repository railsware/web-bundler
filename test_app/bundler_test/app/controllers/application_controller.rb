require 'web_resource_bundler'
class ApplicationController < ActionController::Base
  include WebResourceBundler
  protect_from_forgery
  before_filter :set_settings
  def set_settings
    @settings = {
      :resource_dir => File.join(Rails.root, 'public'),
      :log_path => File.join(Rails.root, '/log/bundler.log')
    }
  end
end
