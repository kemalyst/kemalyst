require "spec"
require "../src/kemalyst"


def create_request_and_return_io(handler, request)
  io = MemoryIO.new
  response = HTTP::Server::Response.new(io)
  context = HTTP::Server::Context.new(request, response)
  handler.call(context)
  response.close
  io.rewind
  io
end

