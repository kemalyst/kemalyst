require "./spec_helper"

describe Kemalyst::Handler::Logger do

  it "logs a request/response" do
    request = HTTP::Request.new("GET", "/")
    context = create_context(request)
    
    router = Kemalyst::Handler::Router.new
    router.add_route("GET", "/", ->(c : HTTP::Server::Context) { "Hello World!" })
    io = MemoryIO.new
    logger = Logger.new(io)
    logger.level = Logger::INFO
    logger = Kemalyst::Handler::Logger.instance logger
    logger.next = router
    logger.call(context)
    #io.rewind
    #io.to_s.should contain "200"
  end

end


