require "./spec_helper"

describe PostController do

  describe PostController::Index do
    
    it "renders all the posts" do
      request = HTTP::Request.new("GET", "/")
      io, context = create_context(request) 
      PostController::Index.instance.call(context)
      io.rewind
      response = HTTP::Client::Response.from_io(io)
      response.body.should contain "Dru's Blog"
    end

  end
end
