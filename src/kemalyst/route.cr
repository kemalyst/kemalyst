# This class holds the method, path and handler for a Route.  An instance of
# this class will be added to the radix tree.

module Kemalyst
  class Route
    getter method
    getter path
    getter handler

    def initialize(@method, @path, @handler)
    end
  
  end
end
