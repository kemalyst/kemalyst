require "json"

module Kemalyst::Handler
  class Params < Base

    def call(context)
      context.clear_params
      parse(context)
      call_next(context)
    end

    def parse(context)
      parse_query(context)
      parse_body(context)
    end

    def parse_query(context)
      parse_part(context, context.request.query)
    end
    
    URL_ENCODED_FORM = "application/x-www-form-urlencoded"
    
    def parse_body(context)
      return if (context.request.headers["Content-Type"]? =~ /#{URL_ENCODED_FORM}/).nil?
      parse_part(context, context.request.body)
    end

    def parse_part(context, part)
      return unless part
      HTTP::Params.parse(part) do |key, value|
        context.params[key] ||= value
      end
    end
  end
end
