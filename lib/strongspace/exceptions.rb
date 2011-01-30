module Strongspace
  module Exceptions
    class StrongspaceError < StandardError; end

    class InvalidCredentials < StrongspaceError
      def message
        "Invalid Strongspace Credentials"
      end
    end

    class NoConnection < StrongspaceError
      def message
        "Could not connect to Strongspace"
      end
    end
  end
end