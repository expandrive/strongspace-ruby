module Strongspace::Command
  class Spaces < Base
    def list
      long = args.any? { |a| a == '--long' }
      spaces = strongspace.spaces

      if spaces.empty?
        display "#{strongspace.username} has no spaces"
      else
        display "=== #{strongspace.username} has #{spaces.size} space#{'s' if spaces.size > 1}"
        spaces.each do |space|
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

    def delete
      strongspace.delete_space(args.first)
      display "Space #{args.first} removed."
    end

    def snapshots
      if args.length == 0
        display "No space specified."
        return
      end
      snapshots = strongspace.snapshots(args.first)

      if snapshots.empty?
        display "Space #{args.first} has no snapshots"
      else
        display "=== Space #{args.first} has #{snapshots.size} snapshot#{'s' if snapshots.size > 1}"
        snapshots.each do |snapshot|
          display "#{args.first}@#{snapshot['name']} [created: #{snapshot['created_at']}]"
        end
      end
    end

    def create_snapshot
      space_name, snapshot_name = args[0..1]

      if snapshot_name.blank?
        snapshot_name = Time.now.strftime("%Y-%m-%d-%H%M%S")
      end

      strongspace.create_snapshot(space_name, snapshot_name)
      display "Created snapshot '#{space_name}@#{snapshot_name}'"
    end

    def create_snapshot_and_thin

      retries = 0
      success = false
      while (!success and (retries < 5)) do
        begin
          create_snapshot
          #thin_snapshots
        rescue SocketError => e
          sleep(10)
          retries = retries + 1
          next
        end
        success = true
      end

    end

    def delete_snapshot
      space_name, snapshot_name = args[0..1]

      strongspace.delete_snapshot(space_name, snapshot_name)
      display "Destroyed snapshot '#{space_name}@#{snapshot_name}'"
    end

    def thin_snapshots
      snapshots = strongspace.snapshots(args.first)

      keeplist = []

      snapshots.each do |s|
        if DateTime.parse(s['created_at']).to_local_time > (Time.now - 3600*24)
          keeplist << s
          next
        end
      end

      (snapshots - keeplist).each do |k|
        puts "Drop: " + k['name']
        strongspace.delete_snapshot(args.first, k['name'])
      end

    end


    def schedule_snapshots
      space_name = args[0]

      if running_on_a_mac?
        plist = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <!DOCTYPE plist PUBLIC -//Apple Computer//DTD PLIST 1.0//EN
        http://www.apple.com/DTDs/PropertyList-1.0.dtd >
        <plist version=\"1.0\">
        <dict>
        <key>Label</key>
        <string>com.strongspace.Snapshots.#{space_name}</string>
        <key>Program</key>
        <string>#{support_directory}/gems/bin/strongspace</string>
        <key>ProgramArguments</key>
        <array>
        <string>strongspace</string>
        <string>spaces:create_snapshot_and_thin</string>
        <string>#{space_name}</string>
        </array>
        <key>KeepAlive</key>
        <false/>
        <key>StartCalendarInterval</key>
        <dict>
          <key>Minute</key>
          <integer>0</integer>
        </dict>
        <key>RunAtLoad</key>
        <true/>
        <key>StandardOutPath</key>
        <string>#{log_file}</string>
        <key>StandardErrorPath</key>
        <string>#{log_file}</string>
        <key>EnvironmentVariables</key>
        <dict>
        <key>STRONGSPACE_DISPLAY</key>
        <string>logging</string>
        <key>GEM_PATH</key>
        <string>#{support_directory}/gems</string>
        <key>GEM_HOME</key>
        <string>#{support_directory}/gems</string>
        <key>RACK_ENV</key>
        <string>production</string>
        </dict>

        </dict>
        </plist>"

        file = File.new(launchd_plist_file(space_name), "w+")
        file.puts plist
        file.close

        r = `launchctl load -S aqua '#{launchd_plist_file(space_name)}'`
        if r.strip.ends_with?("Already loaded")
          error "This task is aready scheduled, unload before scheduling again"
          return
        end
        display "Scheduled Snapshots of #{space_name}"
      end
    end

    def unschedule_snapshots
      space_name = args[0]

      if space_name.blank?
        display "Please supply the name of a space"
        return false
      end

      if running_on_windows?
        error "Scheduling currently isn't supported on Windows"
        return
      end

      if running_on_a_mac?
        if File.exist? launchd_plist_file(space_name)
          `launchctl unload '#{launchd_plist_file(space_name)}'`
          FileUtils.rm(launchd_plist_file(space_name))
        end
      else  # Assume we're running on linux/unix
        CronEdit::Crontab.Remove "strongspace-snapshots-#{space_name}"
      end

    end


    private
    def launchd_plist_file(space_name)
      "#{launchd_agents_folder}/com.strongspace.Snapshots.#{space_name}.plist"
    end

    def log_file
      "#{logs_folder}/Strongspace.log"
    end

  end
end

