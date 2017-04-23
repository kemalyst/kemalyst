require "./spec_helper"

describe Kemalyst::Handler::Flash do
  it "sets a cookie" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    session = Kemalyst::Handler::Flash.instance
    session.call(context)
    context.response.headers.has_key?("set-cookie").should be_true
  end

  it "sets a flash message" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.flash["error"] = "There was a problem"
    context.flash["error"].should eq "There was a problem"
  end

  it "returns a list of flash messages that have not been read" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.flash["error"] = "There was a problem"
    context.flash.unread.size.should eq 1
  end

  it "does not return read messages" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.flash["error"] = "There was a problem"
    context.flash["error"]
    context.flash.unread.size.should eq 0
  end

  it "supports enumerable" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.flash["error"] = "There was a problem"
    context.flash["notice"] = "This is important"
    list = [] of String
    context.flash.map { |k, v| list << v }
    list.size.should eq 2
  end
end
