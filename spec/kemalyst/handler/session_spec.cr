require "./spec_helper"

describe Kemalyst::Handler::Session do
  it "sets a cookie" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    session = Kemalyst::Handler::Session.instance
    session.call(context)
    expect(context.response.headers.has_key?("set-cookie")).to be_true
  end

  it "encodes the session data" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    session = Kemalyst::Handler::Session.instance
    context.session["authorized"] = "true"
    session.call(context)
    cookie = context.response.headers["set-cookie"]
    expect(cookie).to eq "kemalyst.session=6f9654b549f1e60103fc4e9bc34bc7f85d4f290a--eyJhdXRob3JpemVkIjoidHJ1ZSJ9%0A; path=/"
  end

  it "uses a secret" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    session = Kemalyst::Handler::Session.instance
    session.secret = "0c04a88341ec9ffd2794a0d35c9d58109d8fff32dfc48194c2a2a8fc62091190920436d58de598ca9b44dd20e40b1ab431f6dcaa40b13642b69d0edff73d7374"
    context.session["authorized"] = "true"
    session.call(context)
    cookie = context.response.headers["set-cookie"]
    expect(cookie).to eq "kemalyst.session=d5374f304c4a343e14fca421e4c372c777207337--eyJhdXRob3JpemVkIjoidHJ1ZSJ9%0A; path=/"
  end

  context "context" do
    it "holds session hash" do
      request = HTTP::Request.new("GET", "/")
      io, context = create_context(request)
      context.session["test"] = "test"
      expect(context.session.size).to eq 1
    end

    it "clears session hash" do
      request = HTTP::Request.new("GET", "/")
      io, context = create_context(request)
      context.session["test"] = "test"
      context.clear_session
      expect(context.session.size).to eq 0
    end
  end
end
