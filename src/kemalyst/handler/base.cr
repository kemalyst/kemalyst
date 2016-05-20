require "http"

module Kemalyst::Handler
  # The base class for Kemalyst handlers.  This extension provides a singleton
  # method and ability to configure each handler.  All configurations should
  # be maintained in the `/config` folder for consistency.
  class Base < HTTP::Handler
    
    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    # class variables are not inherited. You can use macro inherited
    macro inherited
      def self.instance
        @@instance ||= new
      end
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
