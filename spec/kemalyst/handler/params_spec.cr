require "./spec_helper"

describe Kemalyst::Handler::Params do

  it "parses query params" do
    request = HTTP::Request.new("GET", "/?test=test")
    context = create_context(request)
    
    params = Kemalyst::Handler::Params.instance
    params.call(context)
    context.params["test"].should eq "test"
  end

  it "parses multiple query params" do
    request = HTTP::Request.new("GET", "/?test=test&test2=test2")
    context = create_context(request)
    
    params = Kemalyst::Handler::Params.instance
    params.call(context)
    context.params.size.should eq 2
    context.params["test2"].should eq "test2"
  end

  it "parses body params" do
    headers = HTTP::Headers.new
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    body = "test=test"
    request = HTTP::Request.new("POST", "/", headers, body)
    context = create_context(request)
    params = Kemalyst::Handler::Params.instance
    params.call(context)
    context.params["test"].should eq "test"
  end

  it "parses multiple body params" do
    headers = HTTP::Headers.new
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    body = "test=test&test2=test2"
    request = HTTP::Request.new("POST", "/", headers, body)
    context = create_context(request)
    params = Kemalyst::Handler::Params.instance
    params.call(context)
    context.params.size.should eq 2
    context.params["test2"].should eq "test2"
  end

  it "parses json hash" do
    headers = HTTP::Headers.new
    headers["Content-Type"] = "application/json"
    body = "{\"test\":\"test\"}"
    request = HTTP::Request.new("POST", "/", headers, body)
    context = create_context(request)
    params = Kemalyst::Handler::Params.instance
    params.call(context)
    context.params["test"].should eq "test"
  end

  it "parses json array" do
    headers = HTTP::Headers.new
    headers["Content-Type"] = "application/json"
    body = "[\"test\",\"test2\"]"
    request = HTTP::Request.new("POST", "/", headers, body)
    context = create_context(request)
    params = Kemalyst::Handler::Params.instance
    params.call(context)
    context.params["_json"].should eq ["test","test2"]
  end
end


