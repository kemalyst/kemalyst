module Kemalyst::Handler
  # This Handler adds support for Cross Origin Resource Sharing.
  class Cors < Base
    property allow_origin, allow_headers, allow_methods, allow_credentials,
      max_age

    def initialize
      @allow_origin = "*"
      @allow_headers = "Accept, Content-Type"
      @allow_methods = "GET, HEAD, POST, DELETE, OPTIONS, PUT, PATCH"
      @allow_credentials = false
      @max_age = 0
    end

    def call(context)
      begin
        context.response.headers["access-control-allow-origin"] = @allow_origin
        if @allow_credentials
          context.response.headers["access-control-allow-credentials"] = "true"
        end
        
        if context.request.method.downcase == "options"
          context.response.headers["access-control-allow-headers"] = @allow_headers
          context.response.headers["access-control-allow-methods"] = @allow_methods
          if @max_age > 0
            context.response.headers["access-control-max-age"] = @max_age.to_s
          end
          context.response.status_code = 200
          context.response.content_type = "text/html; charset=utf-8"
          context.response.print("")
        else
          call_next(context)
        end
      end
    end
  
  end
end

