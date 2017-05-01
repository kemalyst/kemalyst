require "./spec_helper"

describe Kemalyst::Handler::Logger do
  it "logs a request/response" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)

    router = Kemalyst::Handler::Router.new
    handler = Kemalyst::Handler::Block.new(->(context : HTTP::Server::Context) { context.response.print "Hello World!" })
    router.add_route("GET", "/", handler)

    loghandler = Kemalyst::Handler::Logger.instance
    loghandler.next = router
    loghandler.call(context)
  end
end
