require "./spec_helper"

describe HTTP::Server::Context do
  it "holds params" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params["test"] = "test"
    expect(context.params.has_key?("test")).to eq true
  end

  it "clears params" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params["test"] = "test"
    context.clear_params
    expect(context.params.has_key?("test")).to eq false
  end

  it "supports multiple params" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.params.add("test", "test1")
    context.params.add("test", "test2")
    expect(context.params.fetch_all("test")).to eq ["test1", "test2"]
  end

  it "holds session" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.session["test"] = "test"
    expect(context.session.size).to eq 1
  end

  it "clears session" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.session["test"] = "test"
    context.clear_session
    expect(context.session.size).to eq 0
  end
end
