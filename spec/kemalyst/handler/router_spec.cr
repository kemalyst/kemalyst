require "./spec_helper"

describe Kemalyst::Handler::Route do
  it "returns the method" do
    route = Kemalyst::Handler::Route.new("GET", "/", Kemalyst::Handler::Block.new(->(context : HTTP::Server::Context) { "Hello World!" }))
    expect(route.method).to eq "GET"
  end

  it "returns the path" do
    route = Kemalyst::Handler::Route.new("GET", "/", Kemalyst::Handler::Block.new(->(context : HTTP::Server::Context) { "Hello World!" }))
    expect(route.path).to eq "/"
  end

  it "returns the handler" do
    handler = Kemalyst::Handler::Block.new(->(context : HTTP::Server::Context) { "Hello World!" })
    route = Kemalyst::Handler::Route.new("GET", "/", handler)
    expect(route.handler).to eq handler
  end
end

describe Kemalyst::Handler::Router do
  it "set content_type to text/html" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)

    router = Kemalyst::Handler::Router.new
    handler = Kemalyst::Handler::Block.new(->(context : HTTP::Server::Context) { "Hello World!" })
    router.add_route("GET", "/", handler)
    router.call(context)
    expect(context.response.headers["content_type"]).to eq "text/html"
  end

  it "set response body to Hello World!" do
    router = Kemalyst::Handler::Router.new
    handler = Kemalyst::Handler::Block.new(->(context : HTTP::Server::Context) { "Hello World!" })
    router.add_route("GET", "/", handler)

    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    router.call(context)
    context.response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io, decompress: false)
    expect(client_response.body).to eq "Hello World!"
  end

  it "builds handler callstack for routes individually in order" do
    router = Kemalyst::Handler::Router.new
    handler = Kemalyst::Handler::Block.new(->(context : HTTP::Server::Context) { "Hello World!" })
    socket = Kemalyst::WebSocket.new
    router.add_route("GET", "/", socket)
    router.add_route("GET", "/", handler)
    result = router.lookup_route("GET", "/")
    expect(result.found?).to eq true
    expect(result.payload.handler.next).to eq handler
  end
end
