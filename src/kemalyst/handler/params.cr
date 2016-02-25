require "json"

module Kemalyst::Handler
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
      parse_body(context)
      parse_json(context)
    end

    def parse_query(context)
      parse_part(context, context.request.query)
    end
    
    
    
    def parse_body(context)
      return if (context.request.headers["Content-Type"]? =~ /#{URL_ENCODED_FORM}/).nil?
      parse_part(context, context.request.body)
    end

    def parse_json(context)
      return if context.request.headers["Content-Type"]? != APPLICATION_JSON

      body = context.request.body as String
      case json = JSON.parse(body).raw
      when Hash
        json.each do |key, value|
          context.params[key as String] = value
        end
      when Array
        context.params["_json"] = json
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
