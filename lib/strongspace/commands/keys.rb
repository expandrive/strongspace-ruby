module Strongspace::Command
  class Keys < Base
    def list
      long = args.any? { |a| a == '--long' }
      keys = strongspace.keys["ssh_keys"]
      if keys.empty?
        display "No keys for #{strongspace.username}"
      else
        display "=== #{keys.size} key#{'s' if keys.size > 1} for #{strongspace.username}"
        keys.each do |key|
          display long ? key["key"].strip : format_key_for_display(key["key"]) + "    key-id: #{key["id"]}"
        end
      end
    end
    alias :index :list

    def generate
      `ssh-keygen`
      return ($? == 0)
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
