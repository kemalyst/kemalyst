module Kemalyst
  class Route
    getter handler
    getter method

    def initialize(@method, @path, &@handler : HTTP::Server::Context -> _)
    end
  end
end
