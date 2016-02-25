module Kemalyst
  class Route
    getter handler
    getter method

    def initialize(@method, @path, &@handler : HTTP::Server::Context -> _)
    end
    def initialize(@method, @path, @handler)
    end
  end
end
