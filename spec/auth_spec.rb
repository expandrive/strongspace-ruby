require File.expand_path("./base", File.dirname(__FILE__))

require "strongspace"

def prepare_command(klass)
  command = klass.new(['--app', 'myapp'])
  command.stub!(:args).and_return([])
  command.stub!(:display)
  command
end



describe Strongspace::Command::Auth do




end