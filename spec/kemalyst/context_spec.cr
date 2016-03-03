require "./spec_helper"

describe HTTP::Server::Context do

  it "holds params" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params["test"] = "test"
    context.params.size.should eq 1
  end
  
  it "params supports Bool" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params["test"] = true
    context.params.size.should eq 1
  end

  it "params supports Int64" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params["test"] = 1_i64
    context.params.size.should eq 1
  end

  it "params supports Float64" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params["test"] = 1.0_f64
    context.params.size.should eq 1
  end

  it "clears params" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params["test"] = "test"
    context.clear_params
    context.params.size.should eq 0
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
