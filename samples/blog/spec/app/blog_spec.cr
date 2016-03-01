require "./spec_helper"


describe Blog::Application do

  it "creates A Blog Application" do
    Blog::Application.instance.port.should eq 3000
  end
end
