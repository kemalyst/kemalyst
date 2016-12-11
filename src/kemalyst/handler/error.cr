require "kilt"

module Kemalyst::Handler
  # The Error Handler catches RouteNotFound and returns a 404.  It will
  # response based on the `Accepts` header as JSON or HTML.  It also catches
  # any runtime Exceptions and returns a backtrace in text/plain format.
  class Error < Base
    property :error_path, :template_type

    def initialize
      @error_path = "error"
      @template_type = "ecr"
    end

    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def call(context)
      begin
        call_next(context)
      rescue ex : Kemalyst::Exceptions::Forbidden
        status_code = 403
        context.response.status_code = status_code

        content_type = content_type(context)
        context.response.content_type = content_type

        message = render_message(ex.message, content_type, status_code)
        context.response.print(message)
      rescue ex : Kemalyst::Exceptions::RouteNotFound
        status_code = 404
        context.response.status_code = status_code

        content_type = content_type(context)
        context.response.content_type = content_type

        message = render_message(ex.message, content_type, status_code)
        context.response.print(message)
      rescue ex : Exception
        status_code = 500
        context.response.status_code = status_code

        content_type = content_type(context)
        context.response.content_type = content_type

        message = render_message(ex.inspect_with_backtrace, content_type, status_code)
        context.response.print(message)
      end
    end

    private def content_type(context)
        if context.request.headers["Accept"]?
          context.request.headers["Accept"].split(",")[0]
        else
          "text/plain"
        end
    end

    private def render_message(message, content_type, status_code)
      case content_type
      when "application/json"
        { "error": message }.to_json
      when "text/html"
        template = "src/views/#{error_path}/#{status_code}.#{template_type}"
        if (File.exists? template)
          Kilt.render "src/views/{{error_path.id}}/{{status_code.id}}.{{template_type.id}}"
        else
          "<html><body>#{message}</body></html>"
        end
      else
        message
      end
    end
  end
end
