require "base64"
require "openssl/sha1"

module Kemalyst::Handler
  class WebSocket < Base

    def initialize(&@proc : WebSocket ->)
    end
    
    def initialize(@proc)
    end

    def call(context)
      if context.request.headers["Upgrade"]? == "websocket" && context.request.headers["Connection"]? == "Upgrade"
        key = context.request.headers["Sec-Websocket-Key"]
        accept_code = Base64.strict_encode(OpenSSL::SHA1.hash("#{key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11"))

        response = context.response
        response.status_code = 101
        response.headers["Upgrade"] = "websocket"
        response.headers["Connection"] = "Upgrade"
        response.headers["Sec-Websocket-Accept"] = accept_code
        response.upgrade do |io|
          ws_session = HTTP::WebSocket.new(io)
          @proc.call(ws_session)
          ws_session.run
          io.close
        end
      else
        call_next(context)
      end
    end
      
  end
end
