require "http"

module Kemalyst::Handler
  # The base class for Kemalyst handlers.  This extension provides a singleton
  # method and ability to configure each handler.  All configurations should
  # be maintained in the `/config` folder for consistency.
  class Base < HTTP::Handler
     
    def self.instance
      @@instance ||= Kemalyst::Handler::Base.new
    end
    
    # Ability to configure the singleton instance from the class
    def self.config
      yield self.instance
    end
   
    # Ability to configure the instance
    def config
      yield self
    end

    # Execution of this handler.
    def call(context)
      call_next context
    end

  end
end
