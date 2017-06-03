require "./spec_helper"

describe Kemalyst::Handler::CSRF do
  context "methods" do
    it "allows GET requests" do
      request = HTTP::Request.new("GET", "/")
      io, context = create_context(request)
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
    end

    it "allows HEAD requests" do
      request = HTTP::Request.new("HEAD", "/")
      io, context = create_context(request)
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
    end

    it "allows OPTION requests" do
      request = HTTP::Request.new("OPTION", "/")
      io, context = create_context(request)
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
    end

    it "rejects PUT requests" do
      request = HTTP::Request.new("PUT", "/")
      io, context = create_context(request)
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
      context.response.close
      io.rewind
      client_response = HTTP::Client::Response.from_io(io, decompress: false)
      expect(client_response.body).to eq "CSRF check failed."
    end

    it "rejects POST requests" do
      request = HTTP::Request.new("POST", "/")
      io, context = create_context(request)
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
      context.response.close
      io.rewind
      client_response = HTTP::Client::Response.from_io(io, decompress: false)
      expect(client_response.body).to eq "CSRF check failed."
    end

    it "rejects PATCH requests" do
      request = HTTP::Request.new("PATCH", "/")
      io, context = create_context(request)
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
      context.response.close
      io.rewind
      client_response = HTTP::Client::Response.from_io(io, decompress: false)
      expect(client_response.body).to eq "CSRF check failed."
    end

    it "rejects DELETE requests" do
      request = HTTP::Request.new("DELETE", "/")
      io, context = create_context(request)
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
      context.response.close
      io.rewind
      client_response = HTTP::Client::Response.from_io(io, decompress: false)
      expect(client_response.body).to eq "CSRF check failed."
    end
  end

  context "token as param" do
    it "accepts request when token matches" do
      request = HTTP::Request.new("PUT", "/")
      io, context = create_context(request)
      context.session["csrf.token"] = "test"
      context.params["_csrf"] = "test"
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
    end

    it "rejects request when token does not match" do
      request = HTTP::Request.new("PUT", "/")
      io, context = create_context(request)
      context.session["csrf.token"] = "test"
      context.params["_csrf"] = "test2"
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
      context.response.close
      io.rewind
      client_response = HTTP::Client::Response.from_io(io, decompress: false)
      expect(client_response.body).to eq "CSRF check failed."
    end
  end

  context "token as header" do
    it "accepts request when token matches" do
      request = HTTP::Request.new("PUT", "/")
      io, context = create_context(request)
      context.session["csrf.token"] = "test"
      context.request.headers["HTTP_X_CSRF_TOKEN"] = "test"
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
    end

    it "rejects request when token does not match" do
      request = HTTP::Request.new("PUT", "/")
      io, context = create_context(request)
      context.session["csrf.token"] = "test"
      context.request.headers["HTTP_X_CSRF_TOKEN"] = "test2"
      csrf = Kemalyst::Handler::CSRF.instance
      csrf.call(context)
      context.response.close
      io.rewind
      client_response = HTTP::Client::Response.from_io(io, decompress: false)
      expect(client_response.body).to eq "CSRF check failed."
    end
  end
end
