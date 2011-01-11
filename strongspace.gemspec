$:.unshift File.expand_path("../lib", __FILE__)
require "strongspace/version"

Gem::Specification.new do |gem|
  gem.name    = "strongspace"
  gem.version = Strongspace::VERSION

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
  gem.add_development_dependency "autotest-fsevent"
  gem.add_development_dependency "rspec",   "~> 1.3.0"
  gem.add_development_dependency "taps",    "~> 0.3.11"
  gem.add_development_dependency "webmock", "~> 1.5.0"
  gem.add_development_dependency "open4"
  gem.add_development_dependency "ruby-fsevent"

  gem.add_dependency "open4"
  gem.add_dependency "cronedit"
  gem.add_dependency "rest-client", "< 1.7.0"
  gem.add_dependency "json_pure",   "< 1.5.0"
end
