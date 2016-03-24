module Kemalyst::Exceptions
  # Route Not Found exception is caught by the Error Handler to render a 404
  # page.
  class RouteNotFound < Exception
  end
end
