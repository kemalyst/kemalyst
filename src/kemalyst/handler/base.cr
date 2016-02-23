require "http"

module Kemalyst::Handler
  class Base < HTTP::Handler

    def self.instance
      @@instance ||= new
    end

    def self.config
      yield self.instance
    end
   
    def call(context)
      call_next context
    end

  end
end
