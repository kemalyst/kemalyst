module Kemalyst::Handler
  # This handler is a wrapper around a block.  This is used to allow a route
  # to be configured with only a block but still provides the call_next
  # method so this block can be chained in the callstack.
  class Block < HTTP::Handler
    def initialize(@block : (HTTP::Server::Context -> String))
    end

    def call(context)
      content = @block.call(context)
    end
  end
end
