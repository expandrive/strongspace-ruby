module Strongspace::Command
  class Keys < Base
    def list
      long = args.any? { |a| a == '--long' }
      keys = strongspace.keys
      if keys.empty?
        display "No keys for #{strongspace.username}"
      else
        display "=== #{keys.size} key#{'s' if keys.size > 1} for #{strongspace.username}"
        keys.each do |key|
          display long ? key["key"].strip : format_key_for_display(key["key"]) + "    key-id: #{key["id"]}"
        end
      end
      keys
    end
    alias :index :list

    def generate
      `ssh-keygen`
      return ($? == 0)
    end

    def generate_for_gui
      return unless running_on_a_mac?
      FileUtils.mkdir "#{credentials_folder}" unless File.exist? "#{credentials_folder}"


      File.open("#{credentials_folder}/known_hosts", "w") do |f|
        f.write "*.strongspace.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEArXBYAoHZWVzLfHNMlgteAbq20AaCVcE1qALqVjYZerIpa3rBjNlv2i/2O8ul3OmSfcQwQGPTnABLqz9cozAbxF01eDfqUiSABUDT6m1/lY1a0V7RGS46Y/KJMVbOb4mVpxDZOVwBQh/DYTu7R55vFc93lXpE+tZboqnuq+LvJIZDqzoGTHIUprRs3sNY8Xegnz+m68P+tV6iLkXMRk8Gh8/IIavN4mXYhWPVbCv6Gqo2XhiYVMrCqLZFKLG0W6uwWY/xOhUjWxKDZMlqhyU/YUsMB5BZc9/x0t+Sc82OL+Eh3IB5EUmmCWnhm/LKxjMIn2UNe48BQqwaU/gozVtVPQ==\n"
      end


      if !File.exist? "#{credentials_folder}/#{hostname}.rsa"
        `/usr/bin/ssh-keygen -f #{credentials_folder}/#{hostname}.rsa -b 2048 -C \" Strongspace App - #{hostname}\" -q -N ""` unless File.exist? "#{credentials_folder}/#{hostname}.rsa"
        args[0] = "#{credentials_folder}/#{hostname}.rsa.pub"
        begin
          add
        rescue RestClient::Conflict => e # Swallow errors if the key already exists on Strongspace
        end
      end
    end

    def add
      keyfile = args.first || find_key
      key = File.read(keyfile)

      display "Uploading ssh public key #{keyfile}"

      strongspace.add_key(key)
    end

    def remove
      strongspace.remove_key(args.first)
      display "Key #{args.first} removed."
    end

    def clear
      strongspace.remove_all_keys
      display "All keys removed."
    end

    def valid_key_gui?
      return unless running_on_a_mac? and File.exist? "#{support_directory}/ssh"

      ret = `ssh -o PreferredAuthentications=publickey -i "#{support_directory}/ssh/#{hostname}.rsa" #{strongspace.username}@#{strongspace.username}.strongspace.com 2>&1`

      if ret.include? "Strongspace"
        display "Valid key installed"
        return true
      end
      display "No valid key installed"
      return false
    end

    protected
      def find_key
        %w(rsa dsa).each do |key_type|
          keyfile = "#{home_directory}/.ssh/id_#{key_type}.pub"
          return keyfile if File.exists? keyfile
        end


        display "No ssh public key found in #{home_directory}/.ssh/id_[rd]sa.pub"
        if not running_on_windows?
          display "  Generate a new key? [yes/no]: ", false
          answer = ask("no")
          if answer.downcase == "yes" or answer.downcase == "y"
            r = Strongspace::Command.run_internal("keys:generate", nil)
            if r
              return find_key
            end
          end
        end

        raise CommandFailed, "No ssh public key available"
      end

      def format_key_for_display(key)
        type, hex, local = key.strip.split(/\s/)
        [type, hex[0,10] + '...' + hex[-10,10], local].join(' ')
      end
  end
end
