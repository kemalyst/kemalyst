require "base64"
require "openssl/sha1"

# The WebSocket Controller provides the ability to upgrade a http connection to
# a websocket connection.  This can be configured for all requests or
# specific paths/methods after the routes handler. Management of the
# sockets and communication will be handled by this controller.
#
# An example class:
# ```
# class Chat < Kemalyst::WebSocket
#   @sockets = [] of HTTP::WebSocket
#   @messages = [] of String
#
#   def call(socket : HTTP::WebSocket)
#     @sockets.push socket
#     socket.on_message do |message|
#       @messages.push message
#       @sockets.each do |a_socket|
#         a_socket.send @messages.to_json
#       end
#     end
#   end
# end
# ```
# This class will manage an array of `HTTP::Websocket`s and configures the
# `on_message` callback that will manage the messages that will be then be
# passed on to all of the other sockets.  You can configure the websocket
# route like this:
# ```
# get "/", [Chat.instance,
#           Index.instance]
# ```
# The first time throught, the `Index` class will render your html page.  The
# javascript in your html page will handle the communication to and from the
# upgraded connection. The next request from your javascript will request a
# WebSocket upgrade.  This will call the Chat instance and pass the upgraded
# HTTP::WebSocket.  Notice that the  WebSocket handler `call_next` if the
# headers do not request for an upgrade.  It passes through the request to the
# next handler in the chain.
class Kemalyst::WebSocket
  include HTTP::Handler

  # class method to return a singleton instance of this Controller
  def self.instance
    @@instance ||= new
  end

  # Override this method to handle the websockets
  def call(socket : HTTP::WebSocket)
    nil
  end

  # This is called in the handler chain and will upgrade the the request to a
  # websocket. The new socket will be passed to the `call` method above.  You
  # will need to override that in order to handle each socket and
  # communication between them.
  def call(context : HTTP::Server::Context)
    if context.request.headers["Upgrade"]? == "websocket" &&
       context.request.headers["Connection"]? == "Upgrade"
      key = context.request.headers["Sec-Websocket-Key"]
      accept_code = Base64.strict_encode(OpenSSL::SHA1.hash("#{key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11"))

      response = context.response
      response.status_code = 101
      response.headers["Upgrade"] = "websocket"
      response.headers["Connection"] = "Upgrade"
      response.headers["Sec-Websocket-Accept"] = accept_code
      response.upgrade do |io|
        ws_session = HTTP::WebSocket.new(io)
        call(ws_session)
        ws_session.run
        io.close
      end
      ""
    else
      call_next(context)
    end
  end

  # Helper method to get the logger
  def logger
    Kemalyst::Application.instance.logger
  end

end
