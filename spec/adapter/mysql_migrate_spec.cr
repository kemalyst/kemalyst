require "./spec_helper"
require "../src/adapter/mysql"

class Post < Kemalyst::Model
  adapter mysql
  sql_mapping({ 
    name: ["VARCHAR(255)", String],
    body: ["TEXT", String]
  })
end

class Post2 < Kemalyst::Model
  adapter mysql
  sql_mapping({ 
    name: ["VARCHAR(255)", String],
    body: ["TEXT", String],
    flag: ["BOOLEAN", Bool]
  }, posts)
end

Post.drop
Post.create

describe Kemalyst::Adapter::Mysql do
  Spec.before_each do
    Post.clear
  end

  describe "#migrate" do
    it "should add any new fields" do
      Post2.migrate
      if results = Post2.query("describe posts;")
        results.size.should eq 6
      else
        raise "describe posts returned nil"
      end
    end
  end

  describe "#prune" do
    it "should remove any fields that are not defined" do
      Post2.drop
      Post2.migrate
      Post.prune
      if results = Post.query("describe posts;")
        results.size.should eq 5
      else
        raise "describe posts returned null"
      end
    end
  end

  describe "#add_field" do
    it "should add a new field" do
      Post.drop
      Post.migrate
      Post.database.add_field("posts", "test", "TEXT")
      if results = Post.query("describe posts;")
        results.size.should eq 6
      else
        raise "describe posts returned nil"
      end
    end
  end

  describe "#rename_field" do
    it "should rename a field" do
      Post.drop
      Post.migrate
      Post.database.rename_field("posts", "name", "old_name", "TEXT")
      if results = Post.query("describe posts;")
        results[1][0].should eq "old_name"
      else
        raise "describe posts returned nil"
      end
    end
  end

  describe "#remove_field" do
    it "should remove a field" do
      Post.drop
      Post.migrate
      Post.database.remove_field("posts", "name")
      if results = Post.query("describe posts;")
        results.size.should eq 4
      else
        raise "describe posts returned nil"
      end
    end
  end

  describe "#copy_field" do
    it "should copy data from field" do
      Post.drop
      Post.migrate
      post = Post.new
      post.name = "Hello"
      post.save
      Post.database.add_field("posts", "test", "VARCHAR(255)")
      Post.database.copy_field("posts", "name", "test")
      if results = Post.query("select test from posts")
        results[0][0].to_s.should eq "Hello"
      else
        raise "copy data failed"
      end
    end
  end
end
