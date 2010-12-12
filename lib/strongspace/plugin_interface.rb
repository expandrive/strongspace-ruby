module Strongspace::PluginInterface

  def self.included(base)
    base.extend Strongspace::PluginInterface
  end

  def command(command, *args)
    Strongspace::Command.run_internal command.to_s, args
  end

  def base_command
    @base_command ||= Strongspace::Command::Base.new(ARGV)
  end

end
