module Strongspace
  class Plugin
    class << self
      include Strongspace::Helpers
    end

    attr_reader :name, :uri

    def self.directory
      File.expand_path("#{support_directory}/plugins")
    end

    def self.list
      Dir["#{directory}/*"].sort.map do |folder|
        File.basename(folder)
      end
    end

    def self.load!
      self.update_support_directory!
      list.each do |plugin|
        begin
          load_plugin(plugin)
        rescue Exception => e
          display "Unable to load plugin: #{plugin}: #{e.message}"
        end
      end
      self.load_default_gem_plugins
    end

    def self.load_default_gem_plugins
      begin
        require 'strongspace-rsync'
      rescue Exception => e
      end
    end

    def self.load_plugin(plugin)
      folder = "#{self.directory}/#{plugin}"
      $: << "#{folder}/lib"    if File.directory? "#{folder}/lib"
      load "#{folder}/init.rb" if File.exists?  "#{folder}/init.rb"
    end

    def self.remove_plugin(plugin)
      FileUtils.rm_rf("#{self.directory}/#{plugin}")
    end

    def self.update_support_directory!
      if running_on_a_mac?
        # if File.exist?("#{home_directory}/.strongspace") and !File.exist?("#{support_directory}")
        #   FileUtils.mv("#{home_directory}/.strongspace", "#{support_directory}")
        # end

        FileUtils.mkdir_p(launchd_agents_folder) unless File.exist? launchd_agents_folder
      end
    end

    def initialize(uri)
      @uri = uri
      guess_name(uri)
    end

    def to_s
      name
    end

    def path
      "#{self.class.directory}/#{name}"
    end

    def install
      FileUtils.mkdir_p(path)
      Dir.chdir(path) do
        system("git init -q")
        if !system("git pull #{uri} master -q")
          FileUtils.rm_rf path
          return false
        end
      end
      true
    end

    def uninstall
      FileUtils.rm_r path if File.directory?(path)
    end

    private
      def guess_name(url)
        @name = File.basename(url)
        @name = File.basename(File.dirname(url)) if @name.empty?
        @name.gsub!(/\.git$/, '') if @name =~ /\.git$/
      end
  end
end
