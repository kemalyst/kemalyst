require "spec"
require "mocks/spec"

class Base
  def self.hello
    puts "Hello"
    "Hello"
  end
end

class Say < Base
  def self.say_hello
    self.hello
  end
end

Mocks.create_mock Say do
  mock self.hello, :inherited
end

describe Say do
  it "says Hello" do
    allow(Say).to receive(self.hello()).and_return("World")
    Say.say_hello.should eq "World"
  end
end
