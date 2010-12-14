[Web Resource Bundler](http://wrb.railsware.com/) - New word in resource management
============================================
Purpose
------------------
The main purpose of WebResourceBundler gem is to minimize request & response
round-trips count.  This could be done by bundling particular resource (css or js) in 
one file. Encoding images in base64 and putting then in css directly.

Functional description
----------------------
WebResourceBundler parse your head html block, finding all css and js resource 
files.
It can bundle resource of particular type in one single file. Base64 filter
encodes images in base64 putting them in css directly. Separate files for IE
and other browsers created. Conditional comments (like `<!--[if IE 6]>`) also
supported. You can use external image hosts to server images in css: 
cdn filter can rewrite image urls for you. Resulted filename is a md5(filenames.sort)

Installation
---------------------

   gem install web_resource_bundler

Usage
-------------------

Firstly you should create your settings file in config dir.
You can set separate settings for each environment

config/web_resource_bundler.yml

    development:
      :base64_filter:
        :use: true
        :max_image_size: 23
        :protocol: http
        :domain: localhost:3000
      :bundle_filter:
        :use: true
      :cdn_filter:
        :use: true
        :http_hosts: ['http://localhost:3000']
        :https_hosts: ['https://localhost:3000']

Then you should create initializer file in
/path/to/your/rails_app/config/initializers/ directory
Let's say it will be web_resource_bundler_init.rb
Then you should put content like this in it.

config/initializers/web_resource_bundler_init.rb

    require 'web_resource_bundler'
    require 'yaml'
    root_dir = Rails.root #or RAILS_ROOT if you are using older rails version than 3 
    environment = Rails.env #or RAILS_ENV in case rails <= 2.3
    settings = { }
    settings_file_path = File.join(root_dir, 'config', 'web_resource_bundler.yml')
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

Now in your view files you can call web_resource_bundler_process helper like this:

    <head>
    <% web_resource_bundler_process do %>
      <%= stylesheet_link_tag :scaffold %>
      <%= javascript_include_tag :defaults %>
      <link type="text/css" rel="stylesheet" href="/stylesheets/somestyle.css"/>
      <%=yield :head %>
      <!--[if lte IE 7]>
         <link type="text/css" rel="stylesheet" href="/stylesheets/ie7fix.css"/>
         <link type="text/css" rel="stylesheet" href="/stylesheets/pngfix.css"/>
      <![endif]-->

    <% end %>
    </head>

Notice:

For Rails < 3
you should use <% web_resource_bundler_process do %>

And For Rails >= 3
use <%= web_resource_bundler_process do %>


And as result you'll have

    <link href="/cache/base64_style_d880a502addaa493b889c0970616430b.css?1290594873" media="screen" rel="stylesheet" type="text/css" />
    <script src="/cache/script_275d311037da40e9c9b8c919a8c08b55.js?1290594873" type="text/javascript"></script>

    <!--[if lte IE 7]>
       <link href="/cache/base64_ie_style_d880a502addaa493b889c0970616430b.css?1290594873" media="screen" rel="stylesheet" type="text/css" />
    <![endif]-->

    <!--[if lte IE 7]>
       <link type="text/css" rel="stylesheet" href="/cache/base64_style_ad801w02addaa493b889c0970616430b.css?1290594873"/>
    <![endif]-->

!!!
Don't forget to clean your cache directory after deploy to clean old bundles


To disable bundling and see raw results add no_bundler param
mysite.com/?no_bundler=1

Recommendations
--------------------

1. Be mindful while organazing and linking your resource files 
WebResourceBundler combines all resource file in one. This resulted file could be huge.
  a. Don't link all resources in layouts!
    Be sure to link resources (css\js) only for pages that using them, in other case your users will be forced
    to download huge css\js files with unused content.
  b. One css for one page.
    Try to slice you css files - separate file for each particular page.
  c. Separate bundle block for crucial resources
    To make crucial resources (basic styles\scripts for user can see basic page layout ASAP) load first - just bundle them in separate web_resource_bundler_process block and put this block at the top of your head block. 

2. Don't set max_image_size to big values. 
The main reason of using Base64 filter is to avoid unnecessary server requests and minimize load time,
but when encoded image is very big, traffic overhead time (encoded image base64 code is bigger for apprx. 30% than source image size) could be bigger than request time. In this case your site could be even slower than without a WebResourceBundler.
Recommended max_image_size value is 1..20kbytes

3. Be careful with third party scripts.
Some third party javascript libs can load another script file on the fly, relative path for this file computed
on the client side. But your scripts are bundled and their relative path changed (cache folder), that's why such script
won't be able to compute loaded file path correctly. You should avoid bundling such tricky javascripts.

4. Unexistent resources handling 
  a. Be sure to link in html only existent resource files, otherwise bundler won't work.
  b. If you have unexistent images in css, bundler will work but you've got info messages in log.
