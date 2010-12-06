module Strongspace::Command
  class Spaces < Base
    def list
      long = args.any? { |a| a == '--long' }
      spaces = strongspace.spaces["spaces"]

      if spaces.empty?
        display "#{strongspace.username} has no spaces"
      else
        display "=== #{strongspace.username} has #{spaces.size} space#{'s' if spaces.size > 1}"
        spaces.each do |space|
          space = space["space"]
          display "#{space['name']} [type: #{space['type']}, snapshots: #{space['snapshots']}]"
        end
      end
    end
    alias :index :list

    def create
      name = args[0]
      type = args[1]

      strongspace.create_space(name, type)
      display "Create space #{name}"
    end

    def destroy
      strongspace.destroy_space(args.first)
      display "Space #{args.first} removed."
    end

    def snapshots
      if args.length == 0
        display "No space specified."
        return
      end
      snapshots = strongspace.snapshots(args.first)["snapshots"]

      if snapshots.empty?
        display "Space #{args.first} has no snapshots"
      else
        display "=== Space #{args.first} has #{snapshots.size} snapshot#{'s' if snapshots.size > 1}"
        snapshots.each do |snapshot|
          snapshot = snapshot["snapshot"]
          display "#{args.first}@#{snapshot['name']} [created: #{snapshot['created_at']}]"
        end
      end
    end

    def create_snapshot
      space_name, snapshot_name = args[0].split("@")

      strongspace.create_snapshot(space_name, snapshot_name)
      display "Created snapshot '#{args[0]}'"
    end

    def destroy_snapshot
      space_name, snapshot_name = args[0].split("@")

      strongspace.destroy_snapshot(space_name, snapshot_name)
      display "Destroyed snapshot '#{args.first}'"
    end

  end
end
