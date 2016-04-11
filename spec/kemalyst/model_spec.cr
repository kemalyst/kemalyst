require "./spec_helper"
require "../../src/adapter/pg"

class Todo < Kemalyst::Model
  adapter pg
  
  sql_mapping({ 
    name: "VARCHAR(255)" 
  })

  def initialize(@name)
  end

  JSON.mapping({
    id: (Nil | Int32),
    name: String
  })
  
end

describe Kemalyst::Model do

  it "should return json" do
    Todo.drop
    Todo.create
    todo = Todo.new("hello")
    todo.save
    todo.to_json.should eq "{\"id\":1,\"name\":\"hello\"}"
    todo.name = "Hello"
    todo.save
    todo.to_json.should eq "{\"id\":1,\"name\":\"Hello\"}"
  end

end

