require "./spec_helper"

describe Kemalyst::Handler::Static do

  it "delivery static html" do
    request = HTTP::Request.new("GET", "/index.html")
    context = create_context(request)
    static = Kemalyst::Handler::Static.instance
    static.public_folder = "spec/sample/public"
    static.call(context)
  end

end


