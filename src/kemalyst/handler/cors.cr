module Kemalyst::Handler
  # This Handler adds support for Cross Origin Resource Sharing.
  class Cors < Base

    def call(context)
      begin
        context.response.headers["access-control-allow-origin"] = "*"
        if context.request.method.downcase == "options"
          context.response.headers["access-control-allow-methods"] = "GET, HEAD, POST, DELETE, OPTIONS, PUT, PATCH"
          context.response.headers["access-control-allow-headers"] = "Accept, Content-Type"
          context.response.status_code = 200
          context.response.content_type = "application/json"
        else
          call_next(context)
        end
      end
    end
  
  end
end

