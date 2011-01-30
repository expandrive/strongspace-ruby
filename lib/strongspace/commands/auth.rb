module Strongspace::Command
  class Auth < Base
    attr_accessor :credentials

    def client
      @client ||= init_strongspace
    end

    def init_strongspace
      client = Strongspace::Client.new(user, password, host)
      client
    end

    # just a stub; will raise if not authenticated
    def check
      client.spaces
    end

    def host
      ENV['STRONGSPACE_HOST'] || 'https://www.strongspace.com'
    end

    def reauthorize_interactve
      @credentials = ask_for_credentials
      write_credentials
    end

    def authorize!
      @credentials = [args.first, args[1]]
      r = Strongspace::Client.auth(@credentials[0], @credentials[1])
      if r
        @credentials[0] = "#{@credentials[0]}/token"
        @credentials[1] = r['api_token']
        write_credentials
        return true
      end

      return false
    end

    def authenticated_login
      if args.blank?
        url = "#{host}/login/#{client.login_token['login_token']}"
      else
        to = URI.escape(args[0][0..1]) + URI.escape(URI.escape(args[0][2..-1])).gsub('&', '%26')
        url = "#{host}/login/#{client.login_token['login_token']}?to=#{to}"
      end
      `open "#{url}"`
    end

    def user    # :nodoc:
      get_credentials
      @credentials[0]
    end

    def password    # :nodoc:
      get_credentials
      @credentials[1]
    end

    def credentials_file
      "#{credentials_folder}/credentials"
    end

    def get_credentials    # :nodoc:
      return if @credentials
      unless @credentials = read_credentials
        @credentials = ask_for_credentials
        save_credentials
      end
      @credentials
    end

    def read_credentials
      File.exists?(credentials_file) and File.read(credentials_file).split("\n")
    end

    def echo_off
      system "stty -echo"
    end

    def echo_on
      system "stty echo"
    end

    def ask_for_credentials
      puts "Enter your Strongspace credentials."

      print "Username or Email: "
      user = ask

      print "Password: "
      password = running_on_windows? ? ask_for_password_on_windows : ask_for_password

      ["#{user}/token", Strongspace::Client.auth(user, password, host)['api_token']]
    end

    def valid_saved_credentials?
      if File.exists?(credentials_file)
        credentials = read_credentials
        r = Strongspace::Client.auth(credentials[0], credentials[1])
        return !r.blank?
      end
      return false
    end

    def ask_for_password_on_windows
      require "Win32API"
      char = nil
      password = ''

      while char = Win32API.new("crtdll", "_getch", [ ], "L").Call do
        break if char == 10 || char == 13 # received carriage return or newline
        if char == 127 || char == 8 # backspace and delete
          password.slice!(-1, 1)
        else
          # windows might throw a -1 at us so make sure to handle RangeError
          (password << char.chr) rescue RangeError
        end
      end
      puts
      return password
    end

    def ask_for_password
      echo_off
      password = ask
      puts
      echo_on
      return password
    end

    def save_credentials
      begin
        write_credentials
        command = 'auth:check'
        Strongspace::Command.run_internal(command, args)
      rescue RestClient::Unauthorized => e
        delete_credentials
        raise e unless retry_login?

        display "\nAuthentication failed"
        @credentials = ask_for_credentials
        @client = init_strongspace
        retry
      rescue Exception => e
        delete_credentials
        raise e
      end
    end

    def retry_login?
      @login_attempts ||= 0
      @login_attempts += 1
      @login_attempts < 3
    end

    def write_credentials
      begin
        FileUtils.mkdir_p(credentials_folder)
      rescue Errno::EEXIST => e

      end

      File.open(credentials_file, 'w') do |f|
        f.puts self.credentials
      end
      set_credentials_permissions
    end

    def set_credentials_permissions
      FileUtils.chmod 0700, File.dirname(credentials_file)
      FileUtils.chmod 0600, credentials_file
    end

    def delete_credentials
      FileUtils.rm_f(credentials_file)
    end
  end
end
