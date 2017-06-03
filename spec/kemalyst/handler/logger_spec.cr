require "./spec_helper"

describe Kemalyst::Handler::Logger do
  it "logs a request/response" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)

    handler = Kemalyst::Handler::Block.new(->(c : HTTP::Server::Context) { "Hello World!" })
    loghandler = Kemalyst::Handler::Logger.instance
    loghandler.next = handler
    loghandler.call(context)
  end
end
