module Kemalyst::Handler
  # This Handler adds support for Cross Origin Resource Sharing.
  class Cors < Base
    property allow_origin, allow_headers, allow_methods

    def initialize
      @allow_origin = "*"
      @allow_headers = "Accept, Content-Type"
      @allow_methods = "GET, HEAD, POST, DELETE, OPTIONS, PUT, PATCH"
    end

    def call(context)
      begin
        context.response.headers["access-control-allow-origin"] = allow_origin
        if context.request.method.downcase == "options"
          context.response.headers["access-control-allow-headers"] = allow_headers
          context.response.headers["access-control-allow-methods"] = allow_methods
          context.response.status_code = 200
          context.response.content_type = "application/json"
        else
          call_next(context)
        end
      end
    end
  
  end
end

