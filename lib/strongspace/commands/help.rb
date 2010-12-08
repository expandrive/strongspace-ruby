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
        group.space
        group.command 'keys',                         'show your user\'s public keys'
        group.command 'keys:add [<path to keyfile>]', 'add a public key'
        group.command 'keys:remove <id> ',            'remove a key by id'
        group.command 'keys:clear',                   'remove all keys'
        group.space
        group.command 'spaces',                        'show your user\'s spaces'
        group.command 'spaces:create <space_name> [type]',        'add a new space. type => (normal,public,backup)'
        group.command 'spaces:delete <space_name> [type]',       'remove a space by and destroy its data'
        group.command 'spaces:snapshots <space_name>',                        'show a space\'s snapshots'
        group.command 'spaces:create_snapshot <space_name@snapshot_name>',            'take a space of a space.'
        group.command 'spaces:delete_snapshot <space_name@snapshot_name>',         'remove a snapshot from a space'
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
        output.puts

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
