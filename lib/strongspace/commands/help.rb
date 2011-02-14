module Strongspace::Command
  class Help < Base
    class HelpGroup < Array
      attr_reader :title

      def initialize(title)
        @title = title
      end

      def command(name, description)
        self << [name, description]
      end

      def space
        self << ['', '']
      end
    end

    def self.groups
      @groups ||= []
    end

    def self.group(title, &block)
      groups << begin
        group = HelpGroup.new(title)
        yield group
        group
      end
    end

    def self.create_default_groups!
      group 'General Commands' do |group|
        group.command 'help',                         'show this usage'
        group.command 'version',                      'show the gem version'
        group.space
        group.command 'upload <local_path> <remote_path>',      'upload a file'
        group.command 'download <remote_path>',      'download a file from Strongspace to the current directory'
        group.command 'mkdir <remote_path>',      'create a folder on Strongspace'
        group.command 'delete <remote_path>',      'delete a file or recursively delete a folder on Strongspace'
        group.command 'quota',      'Show the filesystem quota information'
      end

      group 'SSH Keys' do |group|
        group.command 'keys',                         'show your user\'s public keys'

        if not RUBY_PLATFORM =~ /mswin32|mingw32/
          group.command 'keys:add [<keyfile_path>]', 'Add an public key or generate a new SSH keypair and add'
          group.command 'keys:generate',                'Generate a new SSH keypair'
        else
          group.command 'keys:add [<keyfile_path>]', 'Add an public key'
        end

        group.command 'keys:remove <id> ',            'remove a key by id'
        group.command 'keys:clear',                   'remove all keys'
      end

      group 'Spaces' do |group|
        group.command 'spaces',                        'show your user\'s spaces'
        group.command 'spaces:create <name> [type]',        'add a new space. type => (normal,public,backup)'
        group.command 'spaces:delete <name> [type]',       'remove a space by and destroy its data'
        group.command 'spaces:snapshots <name>',                        'show a space\'s snapshots'
        group.command 'spaces:create_snapshot <name> [snapshot_name]',        'take a space of a space - snapshot_name defaults to current date/time.'
        group.command 'spaces:delete_snapshot <name> <snapshot_name>',         'remove a snapshot from a space'
      end

      group 'Plugins' do |group|
        group.command 'plugins',                      'list installed plugins'
        group.command 'plugins:install <url>',        'install the plugin from the specified git url'
        group.command 'plugins:uninstall <url/name>', 'remove the specified plugin'
      end

    end



    def index
      display usage
    end

    def version
      display Strongspace::Client.version
    end

    def usage
      longest_command_length = self.class.groups.map do |group|
        group.map { |g| g.first.length }
      end.flatten.max

      self.class.groups.inject(StringIO.new) do |output, group|
        output.puts "=== %s" % group.title

        group.each do |command, description|
          if command.empty?
            output.puts
          else
            output.puts "%-*s # %s" % [longest_command_length, command, description]
          end
        end

        output.puts
        output
      end.string
    end
  end
end

Strongspace::Command::Help.create_default_groups!
