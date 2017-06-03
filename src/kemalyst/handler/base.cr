require "http"

module Kemalyst::Handler
  # The base class for Kemalyst handlers.  This extension provides a singleton
  # method and ability to configure each handler.
  class Base
    include HTTP::Handler

    # Ability to configure the singleton instance from the class
    def self.config
      yield self.instance
    end

    # Ability to configure the instance directly
    def config
      yield self
    end

    # Execution of this handler.
    def call(context)
      call_next context
    end
  end
end
