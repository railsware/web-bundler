require 'web_resource_bundler'
class ApplicationController < ActionController::Base
  include WebResourceBundler
  protect_from_forgery
end
