# This class holds the method, path and handler for a Route.  An instance of
# this class will be added to the tree.
class Kemalyst::Route
  getter method
  getter path
  getter handler

  def initialize(@method : String, @path : String, @handler : HTTP::Handler)
  end

end
