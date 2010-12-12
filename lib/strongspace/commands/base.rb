require 'fileutils'
require 'strongspace/plugin_interface'


module Strongspace::Command
  class Base
    include Strongspace::Helpers
    include Strongspace::PluginInterface

    attr_accessor :args
    def initialize(args, strongspace=nil)
      @args = args
      @strongspace = strongspace
    end

    def strongspace
      @strongspace ||= Strongspace::Command.run_internal('auth:client', args)
    end

  end

end
