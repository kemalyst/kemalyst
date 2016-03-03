require "./spec_helper"

describe Kemalyst::Handler::Logger do

  it "logs a request/response" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    
    router = Kemalyst::Handler::Router.new
    router.add_route("GET", "/", ->(c : HTTP::Server::Context) { "Hello World!" })
    log_io = MemoryIO.new
    logger = Logger.new(log_io)
    logger.level = Logger::INFO
    loghandler = Kemalyst::Handler::Logger.instance logger
    loghandler.next = router
    loghandler.call(context)
    logger.close
    log_io.rewind
    log_io.to_s.should contain "200"
  end

end


