require "base64"
require "openssl/sha1"

module Kemalyst::Handler
  # This class provides Basic Authentication capabilities.  The instance
  # requires a username and password to be configured at creation.
  class BasicAuth < Base
    BASIC                 = "Basic"
    AUTH                  = "Authorization"
    AUTH_MESSAGE          = "Could not verify your access level for that URL.\nYou have to login with proper credentials"
    HEADER_LOGIN_REQUIRED = "Basic realm=\"Login Required\""

    @username : String
    @password : String

    def self.instance(username : String, password : String)
      @@instance ||= new(username, password)
    end

    def initialize(@username, @password)
    end

    def call(context)
      if context.request.headers[AUTH]?
        if value = context.request.headers[AUTH]
          if value.size > 0 && value.starts_with?(BASIC)
            return call_next(context) if authorized?(value)
          end
        end
      end
      headers = HTTP::Headers.new
      context.response.status_code = 401
      context.response.headers["WWW-Authenticate"] = HEADER_LOGIN_REQUIRED
      context.response.print AUTH_MESSAGE
      ""
    end

    private def authorized?(value)
      username, password = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")
      @username == username && @password == password
    end
  end
end
