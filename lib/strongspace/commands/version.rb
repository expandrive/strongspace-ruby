module Strongspace::Command
  class Version < Base
    def index
      display Strongspace::Client.gem_version_string
    end
  end
end
