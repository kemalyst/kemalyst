require "./spec_helper"

describe Demo do
 it "returns last_updated formatted" do
    demo = Demo.new
    demo.updated_at = Time.now
    formatter = Time::Format.new("%B %d, %Y")
    demo.last_updated.should eq formatter.format(Time.now)
  end
end
