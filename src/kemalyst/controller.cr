require "http"
require "crack"
require "kilt"
require "kilt/slang"

# The base controller provides a singleton pattern for the HTTP::Handler and
# some macros that provide syntax sugar for rendering a response.
class Kemalyst::Controller
  include HTTP::Handler

  # class method to return a singleton instance of this Controller
  def self.instance
    @@instance ||= new
  end

  # Call is the execution method for this controller.  Controllers can be
  # chained together and should `call_next(context)` if they do not provide
  # the final rendering of the response.
  def call(context)
    call_next context
  end

  # Helper method to get the logger
  def logger
    Kemalyst::Application.instance.logger
  end

  # Provides the CSRF token
  def csrf_token(context)
    Crack::Handler::CSRF.instance.token(context)
  end

  # Helper method to generate a hidden csrf input tag
  def csrf_tag(context)
    Crack::Handler::CSRF.instance.tag(context)
  end

  # action helper to simplify the controllers
  macro action(name, &content)
    class {{name.id.camelcase}} < Kemalyst::Controller
      def call(context)
        params = context.params
        {{content.body}}
      end
    end
  end

  # helper to render a view with a layout.  The view name is relative to `src/views`
  # directory and the layout is relative to `src/views/layouts` directory.
  macro render(filename, layout, *args)
    content = render("{{filename.id}}", {{*args}})
    render("layouts/{{layout.id}}")
  end

  # helper to render a template.  The view name is relative to `src/views` directory.
  macro render(filename, *args)
    Kilt.render("src/views/{{filename.id}}", {{*args}})
  end

  # helper to redirect to another page.  This sets the Location header to
  # the url provided.
  macro redirect(url, status_code = 302)
    context.response.headers.add("Location", {{url}})
    context.response.status_code = {{status_code}}
  end

  # helper to render text.  This sets the content_type to `plain/text`
  macro text(body, status_code = 200)
    context.response.status_code = {{status_code}}
    context.response.content_type = "text/plain"
    context.response.print({{body}})
  end

  # helper to render html.  This sets the content_type to `text/html`
  macro html(body, status_code = 200)
    context.response.status_code = {{status_code}}
    context.response.content_type = "text/html; charset=UTF-8"
    context.response.print({{body}})
  end

  # helper to render json.  This sets the content_type to `application/json`
  macro json(body, status_code = 200)
    context.response.status_code = {{status_code}}
    context.response.content_type = "application/json"
    context.response.print({{body}})
  end

  # helper to render xml.  This sets the content_type to `application/xml`
  macro xml(body, status_code = 200)
    context.response.status_code = {{status_code}}
    context.response.content_type = "application/xml"
    context.response.print({{body}})
  end
end
