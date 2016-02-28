require "./spec_helper"

describe Kemalyst::Handler::Base do

  it "provides an instance" do
    base = Kemalyst::Handler::Base.instance
    base.should eq Kemalyst::Handler::Base.instance
  end

end
