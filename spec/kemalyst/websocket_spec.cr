require "./spec_helper"

describe Kemalyst::WebSocket do
  it "Upgrades to websocket" do
    headers = HTTP::Headers{
      "Upgrade"           => "websocket",
      "Connection"        => "Upgrade",
      "Sec-WebSocket-Key" => "dGhlIHNhbXBsZSBub25jZQ==",
    }
    request = HTTP::Request.new("GET", "/", headers)
    io, context = create_context(request)
    websocket = Kemalyst::WebSocket.new
    handler = Kemalyst::Handler::Block.new(->(context : HTTP::Server::Context) { "Hello World!" })
    router = Kemalyst::Handler::Router.new
    router.add_route("GET", "/", websocket)
    router.add_route("GET", "/", handler)
    router.call(context)
    context.response.close
    io.rewind

    expect(io.to_s).to contain("HTTP/1.1 101 Switching Protocols")
  end
end
