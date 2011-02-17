module Strongspace
  module Helpers

    def command_name
      self.class.name.split("::").last
    end

    def self.home_directory
      running_on_windows? ? ENV['USERPROFILE'] : ENV['HOME']
    end

    def home_directory
      return Strongspace::Helpers.home_directory
    end

    def self.support_directory
      running_on_windows? ? "#{home_directory}\\Strongspace" : "#{home_directory}/Library/Strongspace"
    end

    def support_directory
      return Strongspace::Helpers.support_directory
    end

    def self.running_on_windows?
      RUBY_PLATFORM =~ /mswin32|mingw32/
    end

    def running_on_windows?
      RUBY_PLATFORM =~ /mswin32|mingw32/
    end

    def self.running_on_a_mac?
      RUBY_PLATFORM =~ /-darwin\d/
    end

    def running_on_a_mac?
      RUBY_PLATFORM =~ /-darwin\d/
    end

    def gui_ssh_key
      "#{credentials_folder}/#{computername}.rsa"
    end

    def computername
      n = File.read(credentials_file).split("\n")[2]

      if n.blank?
        if running_on_a_mac?
          @computername ||= `system_profiler  SPSoftwareDataType | grep "Computer Name"`.split(":").last.nice_slug
        elsif running_on_windows?
          @computername ||= ENV['COMPUTERNAME'].nice_slug
        else
          @computername ||= `hostname`.strip.nice_slug
        end

        if @computername.length < 3
          @computername = ENV['USER'].nice_slug
        end

        File.open(credentials_file, 'a') do |f|
          f.puts @computername
        end

      else
        @computername = n.strip
      end

      return @computername
    end

    def credentials_folder
      "#{support_directory}/credentials"
    end

    def credentials_file
      "#{credentials_folder}/credentials"
    end

    def pids_folder
      "#{support_directory}/pids"
    end

    def plugins_folder
      Strongspace::Plugin.directory
    end

    def logs_folder
      if running_on_a_mac?
        "#{home_directory}/Library/Logs/Strongspace"
      else
        "#{support_directory}/logs"
      end
    end

    def bin_folder
      "#{support_directory}/bin"
    end

    def launchd_agents_folder
      "#{support_directory}/LaunchAgents"
    end

    def pid_file_path(name)
      "#{pids_folder}/#{name}"
    end

    def pid_from_pid_file(name)
      if File.exist?(pid_file_path(name))

        f = File.open(pid_file_path(name))
        existing_pid = Integer(f.gets)
        f.close

        return existing_pid
      end

      return nil
    end

    def kill_via_pidfile(name)
      existing_pid = pid_from_pid_file(name)

      if not existing_pid
        return false
      end

      begin
        # This process is running, Kill 0 is a no-op that only works
        # if the process exists
        Process.kill(9, existing_pid)
        return true
      rescue Errno::EPERM
        error "No longer have permissions to check this PID"
        return
      rescue Errno::ESRCH
        # Cleanup orphaned pid file and continue on as normal
        File.unlink(pid_file_path(name))
        return
      rescue
        error "Unable to determine status for #{existing_pid} : #{$!}"
        return
      end

      File.unlink(pid_file_path(name))
      return false
    end

    def process_running?(name)
      existing_pid = pid_from_pid_file(name)

      if not existing_pid
        return false
      end

      begin
        # This process is running, Kill 0 is a no-op that only works
        # if the process exists
        Process.kill(0, existing_pid)
        return true
      rescue Errno::EPERM
        error "No longer have permissions to check this PID"
      rescue Errno::ESRCH
        # Cleanup orphaned pid file and continue on as normal
        File.unlink(pid_file_path(name))
      rescue
        error "Unable to determine status for #{existing_pid} : #{$!}"
      end

      return false
    end

    def create_pid_file(name, pid)

      if process_running?(name)
        return nil
      end

      if not File.exist?(pids_folder)
        FileUtils.mkdir_p(pids_folder)
      end

      file = File.new(pid_file_path(name), "w")
      file.puts "#{pid}"
      file.close

      return true
    end

    def delete_pid_file(name)
      if File.exist?(pid_file_path(name))
        File.unlink(pid_file_path(name))
      end
    end

    def display(msg, newline=true)
      if ENV["STRONGSPACE_DISPLAY"] == "silent"
        return
      end
      if newline
        puts(msg)
      else
        print(msg)
        STDOUT.flush
      end
    end

    def redisplay(line, line_break = false)
      display("\r\e[0K#{line}", line_break)
    end

    def error(msg)
      STDERR.puts(msg)
      exit 1
    end

    def confirm(message="Are you sure you wish to continue? (y/n)?")
      display("#{message} ", false)
      ask.downcase == 'y'
    end

    def confirm_command(app = app)
      if extract_option('--force')
        display("Warning: The --force switch is deprecated, and will be removed in a future release. Use --confirm #{app} instead.")
        return true
      end

      raise(Strongspace::Command::CommandFailed, "No app specified.\nRun this command from app folder or set it adding --app <app name>") unless app

      confirmed_app = extract_option('--confirm', false)
      if confirmed_app
        unless confirmed_app == app
          raise(Strongspace::Command::CommandFailed, "Confirmed app #{confirmed_app} did not match the selected app #{app}.")
        end
        return true
      else
        display "\n !    Potentially Destructive Action"
        display " !    To proceed, type \"#{app}\" or re-run this command with --confirm #{@app}"
        display "> ", false
        if ask.downcase != app
          display " !    Input did not match #{app}. Aborted."
          false
        else
          true
        end
      end
    end

    def format_date(date)
      date = Time.parse(date) if date.is_a?(String)
      date.strftime("%Y-%m-%d %H:%M %Z")
    end

    def ask(default=nil)
      r = gets.strip
      if r.blank?
        return default
      else
        return r
      end
    end

    def shell(cmd)
      FileUtils.cd(Dir.pwd) {|d| return `#{cmd}`}
    end

    def space_exist?(name)
      strongspace.spaces.each do |space|
        # TODO: clean up the json returned by the strongspace API requests to simplify this iteration
        return true if space["name"] == name
      end
      return false
    end


    def backup_space?(name)
      space = nil
      strongspace.spaces.each do |s|
        if s["name"] == name then
          space = s
          break
        end
      end
      return space["type"] == "backup"
    end



  end
end

unless Object.method_defined?(:blank?)
  class Object
    def blank?
      respond_to?(:empty?) ? empty? : !self
    end
  end
end

unless String.method_defined?(:starts_with?)
  class String
    def starts_with?(str)
      str = str.to_str
      head = self[0, str.length]
      head == str
    end
  end
end

unless String.method_defined?(:ends_with?)
  class String
    def ends_with?(str)
      str = str.to_str
      tail = self[-str.length, str.length]
      tail == str
    end
  end
end

unless String.method_defined?(:shellescape)
  class String
    def shellescape
      empty? ? "''" : gsub(/([^A-Za-z0-9_\-.,:\/@\n])/n, '\\\\\\1').gsub(/\n/, "'\n'")
    end
  end
end

unless String.method_defined?(:camelize)
  class String
    def camelize
      self.split(/[^a-z0-9]/i).map{|w| w.capitalize}.join
    end
  end
end

unless String.method_defined?(:underscore)
  class String
    def underscore
      self.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
    end
  end
end

unless String.method_defined?(:nice_slug)
  class String
    def nice_slug
      str = self.dup
      accents = {
      ['á','à','â','ä','ã'] => 'a',
      ['Ã','Ä','Â','À','Á'] => 'A',
      ['é','è','ê','ë'] => 'e',
      ['Ë','É','È','Ê'] => 'E',
      ['í','ì','î','ï'] => 'i',
      ['Í','Î','Ì','Ï'] => 'I',
      ['ó','ò','ô','ö','õ'] => 'o',
      ['Õ','Ö','Ô','Ò','Ó'] => 'O',
      ['ú','ù','û','ü'] => 'u',
      ['Ú','Û','Ù','Ü'] => 'U',
      ['ç'] => 'c', ['Ç'] => 'C',
      ['ñ'] => 'n', ['Ñ'] => 'N'
      }
      accents.each do |ac,rep|
        ac.each do |s|
          str = str.gsub(s, rep)
        end
      end
      str = str.gsub(/[^a-zA-Z0-9\. ]/,"")
      str = str.gsub(/[ ]+/," ")
      str = str.gsub(/[_]/,"-")
    end
  end
end

unless String.method_defined?(:to_cygpath)
  class String
    def to_cygpath
      return self unless Strongspace::Command::running_on_windows?
      r = "/cygdrive/#{self[0..0].downcase}/#{self[3..-1]}".gsub("\\", "/")
      return r
    end
  end
end

unless String.method_defined?(:normalize_pathslash)
  class String
    def normalize_pathslash
      return self.gsub("/", "\\") if Strongspace::Command::running_on_windows?
      return self
    end
  end
end
