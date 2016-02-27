require "../app/controllers/*"
include Kemalyst::Handler

get "/", [ WebSocket.instance(ChatController::Chat.instance),
           BasicAuth.instance("admin", "password"),
           ChatController::Index.instance ]
