require "./spec_helper"
require "../src/adapter/pg"

class User < Kemalyst::Model
  adapter pg
  sql_mapping({ 
    name: ["VARCHAR(255)", String],
    pass: ["TEXT", String]
  })
end

class User2 < Kemalyst::Model
  adapter pg
  sql_mapping({ 
    name: ["VARCHAR(255)", String],
    pass: ["TEXT", String],
    flag: ["BOOLEAN", Bool]
  }, users)
end

User.drop
User.create

describe Kemalyst::Adapter::Pg do
  Spec.before_each do
    User.clear
  end

  describe "#migrate" do
    it "should add any new fields" do
      User2.migrate
      if results = User2.query("SELECT column_name" \
                               " FROM information_schema.columns" \
                               " WHERE table_name = 'users'")
        results.size.should eq 6
      else
        raise "describe users returned nil"
      end
    end
  end

  describe "#prune" do
    it "should remove any fields that are not defined" do
      User2.drop
      User2.migrate
      User.prune
      if results = User2.query("SELECT column_name" \
                               " FROM information_schema.columns" \
                               " WHERE table_name = 'users'")
        results.size.should eq 5
      else
        raise "describe users returned null"
      end
    end
  end

  describe "#add_field" do
    it "should add a new field" do
      User.drop
      User.migrate
      User.database.add_field("users", "test", "TEXT")
      if results = User.query("SELECT column_name" \
                               " FROM information_schema.columns" \
                               " WHERE table_name = 'users'")
        results.size.should eq 6
      else
        raise "describe users returned nil"
      end
    end
  end

  describe "#rename_field" do
    it "should rename a field" do
      User.drop
      User.migrate
      User.database.rename_field("users", "name", "old_name", "TEXT")
      if results = User.query("SELECT column_name" \
                               " FROM information_schema.columns" \
                               " WHERE table_name = 'users'")

        results[1][0].should eq "old_name"
      else
        raise "describe users returned nil"
      end
    end
  end

  describe "#remove_field" do
    it "should remove a field" do
      User.drop
      User.migrate
      User.database.remove_field("users", "name")
      if results = User.query("SELECT column_name" \
                               " FROM information_schema.columns" \
                               " WHERE table_name = 'users'")
        results.size.should eq 4
      else
        raise "describe users returned nil"
      end
    end
  end

  describe "#copy_data" do
    it "should copy data from field" do
      User.drop
      User.migrate
      user = User.new
      user.name = "Hello"
      user.save
      User.database.add_field("users", "test", "VARCHAR(255)")
      User.database.copy_field("users", "name", "test")
      if results = User.query("select test from users")
        results[0][0].to_s.should eq "Hello"
      else
        raise "copy data failed"
      end
    end
  end

end

