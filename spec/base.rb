require 'rubygems'

# ruby 1.9.2 drops . from the load path
$:.unshift File.expand_path("../..", __FILE__)

require 'spec'
require 'fileutils'
require 'tmpdir'
require 'webmock/rspec'

require 'strongspace/command'
require 'strongspace/commands/base'
Dir["#{File.dirname(__FILE__)}/../lib/strongspace/commands/*"].each { |c| require c }

include WebMock::API

def stub_api_request(method, path)
  stub_request(method, "https://www.strongspace.com/api/v1#{path}")
end