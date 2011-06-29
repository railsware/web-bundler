  Gem::Specification.new do |s|
    s.name = %q{web_resource_bundler}
    s.version = "0.0.21"
    s.date = %q{2011-03-19}
    s.summary = %q{lib for css and js content bundling and management}
    s.description = %q{this lib could bundle you css/js files in single file, encode images in base64, rewrite images urls to your cdn hosts}
    s.email = %q{anotheroneman@yahoo.com}
    s.authors = %w{gregolsen amishyn}
    s.homepage = "http://wrb.railsware.com/"
    s.require_path = "lib"
    s.files = Dir["Rakefile", "Readme.md", "VERSION", "lib/**/*", "test/**/*"]
    s.test_files = Dir["spec/**/*"] unless $SAFE > 0
    s.add_development_dependency("rspec", ["= 1.3.1"])
    s.add_dependency("yui-compressor", ["~> 0.9.6"])
  end
