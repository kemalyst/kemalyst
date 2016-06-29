require "./spec_helper"

describe Kemalyst::Controller do

  it "provides csrf token" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.session["csrf.token"] = "test"
    controller = Kemalyst::Controller.instance
    controller.csrf_token(context).should eq "test"
  end

  it "provides csrf tag" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.session["csrf.token"] = "test"
    controller = Kemalyst::Controller.instance
    controller.csrf_tag(context).should eq "<input type=\"hidden\" name=\"_csrf\" value=\"test\" />"
  end

end
