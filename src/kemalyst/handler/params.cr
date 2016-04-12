require "json"

module Kemalyst::Handler
  # The Params handler will parse parameters from a URL, a form post or a JSON
  # post and provide them in the context params hash.  This unifies access to
  # parameters into one place to simplify access to them.
  # Note: other params from the router will be handled in the router handler
  # instead of here.  This removes a dependency on the router in case it is
  # replaced or not needed.
  # TODO: Other content-types need to be supported.
  class Params < Base
    URL_ENCODED_FORM = "application/x-www-form-urlencoded"
    APPLICATION_JSON = "application/json"
    
    def call(context)
      context.clear_params
      parse(context)
      call_next(context)
    end

    def parse(context)
      parse_query(context)
      parse_body(context) if context.request.headers["Content-Type"]? == URL_ENCODED_FORM
      parse_json(context) if context.request.headers["Content-Type"]? == APPLICATION_JSON
    end

    def parse_query(context)
      parse_part(context, context.request.query)
    end
    
    def parse_body(context)
      parse_part(context, context.request.body)
    end

    def parse_json(context)
      if body = context.request.body
        if body.size > 2
          case json = JSON.parse(body).raw
          when Hash
            json.each do |key, value|
              context.params[key as String] = value
            end
          when Array
            context.params["_json"] = json
          end
        end
      end
    end

    private def parse_part(context, part)
      return unless part
      HTTP::Params.parse(part) do |key, value|
        context.params[key] ||= value
      end
    end
  end
end
