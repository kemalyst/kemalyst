require "./spec_helper"

describe Kemalyst::Controller do
  it "provides csrf token" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.session["csrf.token"] = "test"
    controller = Kemalyst::Controller.new(context)
    expect(controller.csrf_token(context)).to eq "test"
  end

  it "provides csrf tag" do
    request = HTTP::Request.new("GET", "/")
    io, context = create_context(request)
    context.session["csrf.token"] = "test"
    controller = Kemalyst::Controller.new(context)
    expect(controller.csrf_tag(context)).to eq "<input type=\"hidden\" name=\"_csrf\" value=\"test\" />"
  end
end
