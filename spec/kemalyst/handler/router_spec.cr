require "./spec_helper"

describe Kemalyst::Handler::Route do
  it "returns the method" do
    route = Kemalyst::Handler::Route.new("GET", "/", Kemalyst::Handler::Base.instance)
    route.method.should eq "GET"
  end

  it "returns the path" do
    route = Kemalyst::Handler::Route.new("GET", "/", Kemalyst::Handler::Base.instance)
    route.path.should eq "/"
  end

  it "returns the handler" do
    route = Kemalyst::Handler::Route.new("GET", "/", Kemalyst::Handler::Base.instance)
    route.handler.should eq Kemalyst::Handler::Base.instance
  end
end

describe Kemalyst::Handler::Router do
  it "set content_type to text/html" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)

    router = Kemalyst::Handler::Router.new
    handler = Kemalyst::Handler::Block.new(->(c : HTTP::Server::Context) { "Hello World!" })
    router.add_route("GET", "/", handler)
    router.call(context)
    context.response.headers["content_type"].should eq "text/html"
  end

  it "set response body to Hello World!" do
    router = Kemalyst::Handler::Router.new
    handler = Kemalyst::Handler::Block.new(->(c : HTTP::Server::Context) { "Hello World!" })
    router.add_route("GET", "/", handler)

    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    router.call(context)
    context.response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io, decompress: false)
    client_response.body.should eq "Hello World!"
  end

  it "builds handler callstack for routes as an array" do
    router = Kemalyst::Handler::Router.new
    handler = Kemalyst::Handler::Block.new(->(c : HTTP::Server::Context) { "Hello World!" })
    socket =Kemalyst::WebSocket.new
    router.add_route("GET", "/", [socket, handler])
    result = router.lookup_route("GET", "/")
    result.found.should eq true
    result.payload.size.should eq 2
  end

  it "builds handler callstack for routes individually in order" do
    router = Kemalyst::Handler::Router.new
    handler = Kemalyst::Handler::Block.new(->(c : HTTP::Server::Context) { "Hello World!" })
    socket =Kemalyst::WebSocket.new
    router.add_route("GET", "/", socket)
    router.add_route("GET", "/", handler)
    result = router.lookup_route("GET", "/")
    result.found.should eq true
    result.payload.size.should eq 2
  end

  it "process_request and clean state" do
    router = Kemalyst::Handler::Router.new
    handler0 = TestHandler.new
    handler1 = Kemalyst::Handler::Block.new(->(c : HTTP::Server::Context) { "Dashboard" })

    router.add_route("GET", "/*", handler0)
    router.add_route("GET", "/dashboard", handler1)

    request = HTTP::Request.new("GET", "/dashboard")
    io, context = create_context(request)
    router.call(context)
    context.response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io, decompress: false)
    client_response.body.should eq "Dashboard"

    request = HTTP::Request.new("GET", "/404")
    io, context = create_context(request)
    router.call(context)
    context.response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io, decompress: false)
    client_response.body.should eq "All"
  end
end
