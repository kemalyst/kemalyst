require "./spec_helper"

describe Kemalyst::Handler::Logger do
  it "logs a request/response" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)

    router = Kemalyst::Handler::Router.new
    router.add_route("GET", "/", TestHandler.instance)

    loghandler = Kemalyst::Handler::Logger.instance
    loghandler.next = router
    loghandler.call(context)
  end
end


