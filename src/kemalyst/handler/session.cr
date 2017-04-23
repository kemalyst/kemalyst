require "http/cookie"
require "base64"
require "json"
require "openssl/hmac"

module Kemalyst::Handler
  # The session handler provides a cookie based session.  The handler will
  # encode and decode the cookie and provide the hash in the context that can
  # be used to maintain data across requests.
  class Session < Base
    property :key, :secret

    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def initialize
      @key = "kemalyst.session"
      @secret = "change_me"
    end

    def call(context)
      cookies = HTTP::Cookies.from_headers(context.request.headers)
      decode(context.session, cookies[@key].value) if cookies.has_key?(@key)
      call_next(context)
      value = encode(context.session)
      cookies = HTTP::Cookies.from_headers(context.response.headers)
      cookies << HTTP::Cookie.new(@key, value)
      cookies.add_response_headers(context.response.headers)
      context
    end

    private def decode (session, data)
      sha1, data = data.split("--", 2)
      if sha1 == OpenSSL::HMAC.hexdigest(:sha1, @secret, data)
        json = Base64.decode_string(data)
        values = JSON.parse(json)
        values.each do |key, value|
          session[key.to_s] = value.to_s
        end
      end
    end

    private def encode (session)
      data = Base64.encode(session.to_json)
      sha1 = OpenSSL::HMAC.hexdigest(:sha1, @secret, data)
      return "#{sha1}--#{data}"
    end
  end
end

# Reopen the context to provide the session methods
class HTTP::Server::Context
  # clear the session.  You can call this to logout a user.
  def clear_session
    @session = {} of String => String
  end

  # Holds a hash of session variables.  This can be used to hold data between
  # sessions.  It's recommended to avoid holding any private data in the
  # session since this is held in a cookie.  Also avoid putting more than 4k
  # worth of data in the session to avoid slow pageload times.
  def session
    @session ||= {} of String => String
  end
end
