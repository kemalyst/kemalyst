require "./spec_helper"

describe Post do

  it "maintaines a list of fields" do
    Post.fields.has_key?("name").should be_true
    Post.fields.has_key?("body").should be_true
  end

  it "adds created_at and updated_at" do
    Post.fields.has_key?("created_at").should be_true
    Post.fields.has_key?("updated_at").should be_true
  end

  it "returns last_updated formatted" do
    post = Post.new
    post.updated_at = Time.now
    formatter = Time::Format.new("%B %d, %Y")
    post.last_updated.should eq formatter.format(Time.now)
  end

  it "returns markdown for body" do
    post = Post.new
    post.body = "# Title"
    post.markdown_body.should eq "<h1>Title</h1>"
  end
  
end
