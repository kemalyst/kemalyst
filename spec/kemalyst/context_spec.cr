require "./spec_helper"

describe HTTP::Server::Context do

  it "holds params" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params["test"] = "test"
    context.params.has_key?("test").should eq true
  end
  
  it "clears params" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params["test"] = "test"
    context.clear_params
    context.params.has_key?("test").should eq false
  end

  it "supports multiple params" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params.add("test", "test1")
    context.params.add("test", "test2")
    context.params.fetch_all("test").should eq ["test1", "test2"]
  end

  it "holds session" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.session["test"] = "test"
    context.session.size.should eq 1
  end

  it "clears session" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.session["test"] = "test"
    context.clear_session
    context.session.size.should eq 0
  end

end
