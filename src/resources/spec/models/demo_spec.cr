require "./spec_helper"

describe Demo do
 it "returns last_updated formatted" do
    post = Post.new
    post.updated_at = Time.now
    formatter = Time::Format.new("%B %d, %Y")
    post.last_updated.should eq formatter.format(Time.now)
  end
end
