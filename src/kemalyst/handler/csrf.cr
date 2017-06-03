require "secure_random"

module Kemalyst::Handler
  # The CSRF Handler adds support for Cross Site Request Forgery.
  # DEPENDENT: Session and Params Handlers.  
  class CSRF < Base
    property session_key, header_key, param_key, check_methods

    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def initialize
      @session_key = "csrf.token"
      @header_key = "HTTP_X_CSRF_TOKEN"
      @param_key = "_csrf"
      @check_methods = "PUT, POST, PATCH, DELETE"
    end

    def call(context)
      if !check_methods.includes?(context.request.method) ||
         context.params.fetch(param_key, nil) == token(context) ||
         context.request.headers.fetch(header_key, nil) == token(context)
        call_next(context)
      else
        context.response.status_code = 403
        if context.request.headers["Accept"]?
          content_type = context.request.headers["Accept"].split(",")[0]
        else
          content_type = "text/plain"
        end
        context.response.content_type = content_type
        context.response.print("CSRF check failed.")
      end
    end

    def token(context)
      context.session[session_key] ||= SecureRandom.urlsafe_base64(32)
    end

    def tag(context)
      %Q(<input type="hidden" name="#{param_key}" value="#{token(context)}" />)
    end
  end
end
