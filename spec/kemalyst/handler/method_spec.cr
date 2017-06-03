require "./spec_helper"

describe Crack::Handler::Method do
  it "overrides method when params key exists" do
    request = HTTP::Request.new("GET", "/?_method=delete")
    io, context = create_context(request)

    params_handler = Crack::Handler::Params.instance
    method_handler = Crack::Handler::Method.instance
    block_handler = Crack::Handler::Block.new(->(c : HTTP::Server::Context) { "Hello World!" })
    params_handler.next = method_handler
    method_handler.next = block_handler
    params_handler.call(context)
    expect(request.method).to eq("delete")
  end

  it "overrides method when header key exists" do
    request = HTTP::Request.new("GET", "/")
    request.headers["HTTP_X_HTTP_METHOD_OVERRIDE"] = "delete"
    io, context = create_context(request)

    params_handler = Crack::Handler::Params.instance
    method_handler = Crack::Handler::Method.instance
    block_handler = Crack::Handler::Block.new(->(c : HTTP::Server::Context) { "Hello World!" })
    params_handler.next = method_handler
    method_handler.next = block_handler
    params_handler.call(context)
    expect(request.method).to eq("delete")
  end
 
end

