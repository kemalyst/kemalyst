require "./spec_helper"

describe Kemalyst::Handler::Params do
  context "query params" do
    it "parses query params" do
      request = HTTP::Request.new("GET", "/?test=test")
      io, context = create_context(request)
      params = Kemalyst::Handler::Params.instance
      params.call(context)
      expect(context.params["test"]).to eq "test"
    end

    it "parses multiple query params" do
      request = HTTP::Request.new("GET", "/?test=test&test2=test2")
      io, context = create_context(request)
      params = Kemalyst::Handler::Params.instance
      params.call(context)
      expect(context.params["test2"]).to eq "test2"
    end
  end

  context "body params" do
    it "parses body params" do
      headers = HTTP::Headers.new
      headers["Content-Type"] = "application/x-www-form-urlencoded"
      body = "test=test"
      request = HTTP::Request.new("POST", "/", headers, body)
      io, context = create_context(request)
      params = Kemalyst::Handler::Params.instance
      params.call(context)
      expect(context.params["test"]).to eq "test"
    end

    it "parses body params with charset" do
      headers = HTTP::Headers.new
      headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
      body = "test=test"
      request = HTTP::Request.new("POST", "/", headers, body)
      io, context = create_context(request)
      params = Kemalyst::Handler::Params.instance
      params.call(context)
      expect(context.params["test"]?).to eq "test"
    end

    it "parses multiple body params" do
      headers = HTTP::Headers.new
      headers["Content-Type"] = "application/x-www-form-urlencoded"
      body = "test=test&test2=test2"
      request = HTTP::Request.new("POST", "/", headers, body)
      io, context = create_context(request)
      params = Kemalyst::Handler::Params.instance
      params.call(context)
      expect(context.params["test2"]).to eq "test2"
    end
  end

  context "json content-type" do
    it "parses json hash" do
      headers = HTTP::Headers.new
      headers["Content-Type"] = "application/json"
      body = "{\"test\":\"test\"}"
      request = HTTP::Request.new("POST", "/", headers, body)
      io, context = create_context(request)
      params = Kemalyst::Handler::Params.instance
      params.call(context)
      expect(context.params["test"]).to eq "test"
    end

    it "parses json array" do
      headers = HTTP::Headers.new
      headers["Content-Type"] = "application/json"
      body = "[\"test\",\"test2\"]"
      request = HTTP::Request.new("POST", "/", headers, body)
      io, context = create_context(request)
      params = Kemalyst::Handler::Params.instance
      params.call(context)
      expect(context.params["_json"]).to eq "[\"test\", \"test2\"]"
    end
  end

  context "multi-part form" do
    it "parses files from multipart forms" do
      headers = HTTP::Headers.new
      # headers["Content-Type"] = "multipart/form-data; boundary=aA40"
      headers["Content-Type"] = "multipart/form-data; boundary=fhhRFLCazlkA0dX"
      body = "--fhhRFLCazlkA0dX\r\nContent-Disposition: form-data; name=\"_csrf\"\r\n\r\nPcCFp4oKJ1g-hZ-P7-phg0alC51pz7Pl12r0ZOncgxI\r\n--fhhRFLCazlkA0dX\r\nContent-Disposition: form-data; name=\"title\"\r\n\r\ntitle field\r\n--fhhRFLCazlkA0dX\r\nContent-Disposition: form-data; name=\"picture\"; filename=\"index.html\"\r\nContent-Type: text/html\r\n\r\n<head></head><body>Hello World!</body>\r\n\r\n--fhhRFLCazlkA0dX\r\nContent-Disposition: form-data; name=\"content\"\r\n\r\nseriously\r\n--fhhRFLCazlkA0dX--"
      # body = "--aA40\r\nContent-Disposition: form-data; name=\"file1\"; filename=\"field.txt\"\r\n\r\nfield data\r\n--aA40--"
      request = HTTP::Request.new("POST", "/", headers, body)
      io, context = create_context(request)
      params = Kemalyst::Handler::Params.instance
      params.call(context)
      expect(context.files["picture"].filename).to eq "index.html"
      expect(context.params["title"]).to eq "title field"
      expect(context.params["_csrf"]).to eq "PcCFp4oKJ1g-hZ-P7-phg0alC51pz7Pl12r0ZOncgxI"
    end
  end

  context "context" do
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
  end
end
