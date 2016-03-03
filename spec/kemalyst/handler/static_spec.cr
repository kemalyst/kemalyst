require "./spec_helper"

describe Kemalyst::Handler::Static do

  it "delivery static html" do
    request = HTTP::Request.new("GET", "/index.html")
    io, context = create_context(request)
    static = Kemalyst::Handler::Static.instance
    static.public_folder = "spec/sample/public"
    static.call(context)
    context.response.close
    io.rewind
    client_response = HTTP::Client::Response.from_io(io, decompress: false)
    client_response.body.should eq "Hello World!\n" 
  end

end


