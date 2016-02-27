module Kemalyst
  class Route
    getter handler
    getter method

    def initialize(@method, @path, @handler)
    end
  
  end
end
