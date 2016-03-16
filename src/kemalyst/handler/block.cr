module Kemalyst::Handler
  class Block < HTTP::Handler

    def initialize(@block : (HTTP::Server::Context -> String))
    end

    def call(context)
      content = @block.call(context)
    end
  end
end
