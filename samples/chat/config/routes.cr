require "../app/controllers/*"
include Kemalyst::Handler

get "/", [ WebSocket.new(ChatController::Chat.instance),
           BasicAuth.new("admin", "password"),
           ChatController::Index.instance ]
