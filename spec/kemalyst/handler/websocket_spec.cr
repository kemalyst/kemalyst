require "./spec_helper"

describe Kemalyst::Handler::WebSocket do
#TODO: trackdown issue with MemoryIO
  it "Upgrades to websocket" do
    headers = HTTP::Headers{
    #  "Upgrade":           "websocket",
      "Connection":        "Upgrade",
      "Sec-WebSocket-Key": "dGhlIHNhbXBsZSBub25jZQ==",
    }
    request = HTTP::Request.new("GET", "/", headers)
    context = create_context(request)
    router = Kemalyst::Handler::Router.new
    router.add_route("GET", "/", [Kemalyst::Handler::WebSocket.new(->(s : HTTP::WebSocket){})], 
      ->(c : HTTP::Server::Context) { "Hello World!" })
    router.call(context)

    #context.response.output.to_s.should eq("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-Websocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=\r\n\r\n")
  end
end


