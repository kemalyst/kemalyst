require "./spec_helper"

describe Kemalyst::Route do

  it "returns the method" do
    route = Kemalyst::Route.new("GET", "/", Kemalyst::Handler::Base.instance)
    route.method.should eq "GET"
  end

  it "returns the path" do
    route = Kemalyst::Route.new("GET", "/", Kemalyst::Handler::Base.instance)
    route.path.should eq "/"
  end
  
  it "returns the handler" do
    route = Kemalyst::Route.new("GET", "/", Kemalyst::Handler::Base.instance)
    route.handler.should eq Kemalyst::Handler::Base.instance
  end

end
