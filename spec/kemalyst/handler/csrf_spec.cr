require "./spec_helper"

describe Kemalyst::Handler::CSRF do
  context "methods" do
    it "should allow GET requests" do
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
      begin
        request = HTTP::Request.new("PUT", "/")
        io, context = create_context(request)
        csrf = Kemalyst::Handler::CSRF.instance
        csrf.call(context)
      rescue ex : Kemalyst::Exceptions::Forbidden
        ex.message.should eq "CSRF check failed."
      end
    end

    it "rejects POST requests" do
      begin
        request = HTTP::Request.new("POST", "/")
        io, context = create_context(request)
        csrf = Kemalyst::Handler::CSRF.instance
        csrf.call(context)
      rescue ex : Kemalyst::Exceptions::Forbidden
        ex.message.should eq "CSRF check failed."
      end
    end

    it "rejects PATCH requests" do
      begin
        request = HTTP::Request.new("PATCH", "/")
        io, context = create_context(request)
        csrf = Kemalyst::Handler::CSRF.instance
        csrf.call(context)
      rescue ex : Kemalyst::Exceptions::Forbidden
        ex.message.should eq "CSRF check failed."
      end
    end

    it "rejects DELETE requests" do
      begin
        request = HTTP::Request.new("DELETE", "/")
        io, context = create_context(request)
        csrf = Kemalyst::Handler::CSRF.instance
        csrf.call(context)
      rescue ex : Kemalyst::Exceptions::Forbidden
        ex.message.should eq "CSRF check failed."
      end
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

    it "rejects request when token matches" do
      begin
        request = HTTP::Request.new("PUT", "/")
        io, context = create_context(request)
        context.session["csrf.token"] = "test"
        context.params["_csrf"] = "test2"
        csrf = Kemalyst::Handler::CSRF.instance
        csrf.call(context)
      rescue ex : Kemalyst::Exceptions::Forbidden
        ex.message.should eq "CSRF check failed."
      end
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

    it "rejects request when token matches" do
      begin
        request = HTTP::Request.new("PUT", "/")
        io, context = create_context(request)
        context.session["csrf.token"] = "test"
        context.request.headers["HTTP_X_CSRF_TOKEN"] = "test2"
        csrf = Kemalyst::Handler::CSRF.instance
        csrf.call(context)
      rescue ex : Kemalyst::Exceptions::Forbidden
        ex.message.should eq "CSRF check failed."
      end
    end
  end
end
