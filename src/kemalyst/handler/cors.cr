module Kemalyst::Handler
  # This Handler adds support for Cross Origin Resource Sharing.
  class Cors < Base

    def call(context)
      begin
        context.response.headers["Access-Control-Allow-Origin"] = "*"
        if context.request.method.downcase == "options"
          context.response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE"
          # context.response.headers["Access-Control-Allow-Headers"] = "X-Custom-Header"
          context.response.status_code = 200
          context.response.content_type = "application/json"
        else
          call_next(context)
        end
      end
    end
  
  end
end

