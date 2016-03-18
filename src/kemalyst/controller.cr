require "http"
require "kilt"

module Kemalyst
  class Controller < HTTP::Handler

    def self.instance
      @@instance ||= new
    end

    def call(context)
      call_next context
    end

    macro render(filename, layout)
      content = render("{{filename.id}}")
      layout = render("layouts/{{layout.id}}")
    end

    macro render(filename, *args)
      content = Kilt.render("src/views/{{filename.id}}", {{*args}})
    end

    macro redirect(url, status_code = 302)
      context.response.headers.add("Location", {{url}})
      context.response.status_code = {{status_code}}
      return ""
    end

    macro text(body, status_code = 200)
      context.response.status_code = {{status_code}}
      context.response.content_type = "text/plain"
      return {{body}}
    end
   
    macro html(body, status_code = 200)
      context.response.status_code = {{status_code}}
      context.response.content_type = "text/html"
      return {{body}}
    end

    macro json(body, status_code = 200)
      context.response.status_code = {{status_code}}
      context.response.content_type = "application/json"
      return {{body}}
    end
  end
end

