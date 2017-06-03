module Kemalyst::Handler
  # The method handler looks for a param["_method"] and overrides the `request.method` with it.
  # This will allow form submits using POST to override the method to match a RESTful backend.
  # DEPENDENT: params handler
  class Method < Base
    property params_key : String
    property header_key : String

    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def initialize
      @params_key = "_method"
      @header_key = "HTTP_X_HTTP_METHOD_OVERRIDE"
    end

    def call(context)
      if context.params.has_key? @params_key
        context.request.method = context.params[@params_key]
      end

      if context.request.headers.has_key? @header_key
        context.request.method = context.request.headers[@header_key]
      end

      call_next(context)
    end
  end
end
