require "./spec_helper"

describe Kemalyst::Handler::BasicAuth do
  it "returns 401 if no Authorization Header" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    basicauth = Kemalyst::Handler::BasicAuth.instance("username", "password")
    basicauth.call(context)
    expect(context.response.status_code.should eq 401
  end

  it "returns 401 if Authorization Header doesn't start with Basic" do
    request = HTTP::Request.new("GET", "/")
    request.headers["Authorization"] = "BAD"
    io, context = create_context(request)
    basicauth = Kemalyst::Handler::BasicAuth.instance("username", "password")
    basicauth.call(context)
    expect(context.response.status_code.should eq 401
  end

  it "returns 401 if bad:user" do
    request = HTTP::Request.new("GET", "/")
    request.headers["Authorization"] = "Basic YmFkOnVzZXI="
    io, context = create_context(request)
    basicauth = Kemalyst::Handler::BasicAuth.instance("username", "password")
    basicauth.call(context)
    expect(context.response.status_code.should eq 401
  end

  it "continues if username:password" do
    request = HTTP::Request.new("GET", "/")
    request.headers["Authorization"] = "Basic dXNlcm5hbWU6cGFzc3dvcmQ="
    io, context = create_context(request)
    basicauth = Kemalyst::Handler::BasicAuth.instance("username", "password")
    basicauth.call(context)
    expect(context.response.status_code.should eq 404
  end
end
