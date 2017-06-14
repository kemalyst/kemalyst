module Kemalyst::Handler
  # The method handler looks for a param["_method"] and overrides the `request.method` with it.
  # This will allow form submits using POST to override the method to match a RESTful backend.
  # DEPENDENT: params handler
  class Method < Base
    PARAMS_KEY = "_method"
    HEADER_KEY = "X-HTTP-Method-Override"

    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def call(context)
      if context.params.has_key? PARAMS_KEY
        context.request.method = context.params[PARAMS_KEY]
      end

      if context.request.headers.has_key? HEADER_KEY
        context.request.method = context.request.headers[HEADER_KEY]
      end

      call_next(context)
    end
  end
end
