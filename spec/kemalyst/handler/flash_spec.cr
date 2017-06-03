require "./spec_helper"

describe Kemalyst::Handler::Flash do
  it "sets a cookie" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    session = Kemalyst::Handler::Flash.instance
    session.call(context)
    expect(context.response.headers.has_key?("set-cookie")).to be_true
  end

  it "sets a flash message" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.flash["error"] = "There was a problem"
    expect(context.flash["error"]).to eq "There was a problem"
  end

  it "returns a list of flash messages that have not been read" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.flash["error"] = "There was a problem"
    expect(context.flash.unread.size).to eq 1
  end

  it "does not return read messages" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.flash["error"] = "There was a problem"
    context.flash["error"]
    expect(context.flash.unread.size).to eq 0
  end

  it "supports enumerable" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.flash["error"] = "There was a problem"
    context.flash["notice"] = "This is important"
    list = [] of String
    context.flash.map { |k, v| list << v }
    expect(list.size).to eq 2
  end
end
