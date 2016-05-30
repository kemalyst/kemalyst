require "../src/controllers/*"
include Kemalyst::Handler::Router
include Kemalyst::Handler

get "/", [WebSocket.instance(ChatController::Chat.instance),
          ChatController::Index.instance]
