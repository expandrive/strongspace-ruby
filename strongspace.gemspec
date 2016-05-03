$:.unshift File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.name    = "strongspace"
  gem.version = "0.3.7"

  gem.author   = "Strongspace"
  gem.email    = "support@strongspace.com"
  gem.homepage = "https://www.strongspace.com/"

  gem.summary     = "Client library and CLI for Strongspace."
  gem.description = "Client library and command line tool for Strongspace."
  gem.homepage    = "http://github.com/expandrive/strongspace"
  gem.executables = ["strongspace", "ss"]

  gem.files = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }

  gem.add_development_dependency "rake"
  gem.add_development_dependency "ZenTest"
  gem.add_development_dependency "autotest-growl"
 # gem.add_development_dependency "autotest-fsevent"
  gem.add_development_dependency "rspec",   "~> 1.3.0"
  gem.add_development_dependency "webmock", "~> 1.5.0"
 # gem.add_development_dependency "ruby-fsevent"


  gem.add_development_dependency "sinatra"
  gem.add_development_dependency "sinatra-reloader"
  gem.add_development_dependency "hoptoad_notifier", " ~> 2.4"

  gem.add_dependency "open4"  # this is required for non-windows
#  gem.add_dependency "win32-open3" # this is required for windows, will fail elsehwere - comment out
  gem.add_dependency "POpen4"
  gem.add_dependency "cronedit"
  gem.add_dependency "rest-client", "1.6.1"
  gem.add_dependency "json_pure",   "1.8.3"
end
