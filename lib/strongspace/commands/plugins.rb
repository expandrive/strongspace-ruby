module Strongspace::Command
  class Plugins < Base
    def list
      ::Strongspace::Plugin.list.each do |plugin|
        display plugin
      end
    end
    alias :index :list

    def install
      plugin = Strongspace::Plugin.new(args.shift)
      if plugin.install
        begin
          Strongspace::Plugin.load_plugin(plugin.name)
        rescue Exception => ex
          installation_failed(plugin, ex.message)
        end
        display "#{plugin} installed"
      else
        error "Could not install #{plugin}. Please check the URL and try again"
      end
    end

    def uninstall
      plugin = Strongspace::Plugin.new(args.shift)
      plugin.uninstall
      display "#{plugin} uninstalled"
    end

    protected

      def installation_failed(plugin, message)
        plugin.uninstall
        error <<-ERROR
Could not initialize #{plugin}: #{message}
        ERROR
      end
  end
end
