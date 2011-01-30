module Strongspace; end

require 'rest_client'
require 'uri'
require 'json/pure' unless {}.respond_to?(:to_json)
require 'fileutils'

STRONGSPACE_LIB_PATH = File.dirname(__FILE__) + "/strongspace/"

[
 "version",
 "exceptions",
 "client",
 "helpers",
 "plugin_interface",
 "plugin",
 "command",
 "commands/base"
].each do |library|
  require STRONGSPACE_LIB_PATH + library
end


Dir["#{STRONGSPACE_LIB_PATH}/commands/*.rb"].each { |c| require c }
