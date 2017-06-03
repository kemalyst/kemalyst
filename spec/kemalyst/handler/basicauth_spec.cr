require "./spec_helper"

describe Kemalyst::Handler::BasicAuth do
  it "successful if username and password match" do
    Kemalyst::Handler::BasicAuth.instance.config do |config|
      config.username = "username"
      config.password = "password"
    end
    request = HTTP::Request.new("GET", "/")
    request.headers["Authorization"] = "Basic dXNlcm5hbWU6cGFzc3dvcmQ="
    io, context = create_context(request)
    basicauth = Kemalyst::Handler::BasicAuth.instance
    basicauth.call(context)
    expect(context.response.status_code).to eq 404
  end

  it "allows setting username and password in instance method" do
    request = HTTP::Request.new("GET", "/")
    request.headers["Authorization"] = "Basic dXNlcm5hbWU6cGFzc3dvcmQ="
    io, context = create_context(request)
    basicauth = Kemalyst::Handler::BasicAuth.instance("username", "password")
    basicauth.call(context)
    expect(context.response.status_code).to eq 404
  end

  it "returns 401 if username and password do not match" do
    request = HTTP::Request.new("GET", "/")
    request.headers["Authorization"] = "Basic dXNlcm5hbWU6cGFzc3dvcmQ="
    io, context = create_context(request)
    basicauth = Kemalyst::Handler::BasicAuth.instance("wrongusername", "doesnotmatch")
    basicauth.call(context)
    expect(context.response.status_code).to eq 404
  end

  it "returns 401 if username and password are not set" do
    request = HTTP::Request.new("GET", "/")
    request.headers["Authorization"] = "Basic YmFkOnVzZXI="
    io, context = create_context(request)
    basicauth = Kemalyst::Handler::BasicAuth.instance
    basicauth.call(context)
    expect(context.response.status_code).to eq 401
  end

  it "returns 401 if no Authorization Header" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    basicauth = Kemalyst::Handler::BasicAuth.instance
    basicauth.call(context)
    expect(context.response.status_code).to eq 401
  end

  it "returns 401 if Authorization Header doesn't start with Basic" do
    request = HTTP::Request.new("GET", "/")
    request.headers["Authorization"] = "BAD"
    io, context = create_context(request)
    basicauth = Kemalyst::Handler::BasicAuth.instance
    basicauth.call(context)
    expect(context.response.status_code).to eq 401
  end
end
