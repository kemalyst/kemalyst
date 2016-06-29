require "http"
require "kilt"

# The base controller provides a singleton pattern for the HTTP::Handler and
# some macros that provide syntax sugar for rendering a response.
class Kemalyst::Controller < HTTP::Handler
  
  # class method to return a singleton instance of this Controller
  def self.instance
    @@instance ||= new
  end

  # Call is the execution method for this controller.  Controllers can be
  # chained together and should `call_next(context)` if they do not provide
  # the final rendering of the response.  If they are the last leaf in the
  # chain, then they should return a String that will be printed to the
  # response io.
  def call(context)
    call_next context
  end

  # Provides the CSRF token
  def csrf_token(context)
    Kemalyst::Handler::CSRF.instance.token(context)
  end

  # Helper method to generate a hidden csrf input tag
  def csrf_tag(context)
    Kemalyst::Handler::CSRF.instance.tag(context)
  end

  # helper to render a view with a layout.  The view name is relative to `src/views`
  # directory and the layout is relative to `src/views/layouts` directory.
  macro render(filename, layout)
    content = render("{{filename.id}}")
    layout = render("layouts/{{layout.id}}")
  end

  # helper to render a template.  The view name is relative to `src/views` directory.
  macro render(filename, *args)
    content = Kilt.render("src/views/{{filename.id}}", {{*args}})
  end

  # helper to redirect to another page.  This sets the Location header to
  # the url provided.
  macro redirect(url, status_code = 302)
    context.response.headers.add("Location", {{url}})
    context.response.status_code = {{status_code}}
    return ""
  end

  # helper to render text.  This sets the content_type to `plain/text`
  macro text(body, status_code = 200)
    context.response.status_code = {{status_code}}
    context.response.content_type = "text/plain"
    return {{body}}
  end
 
  # helper to render html.  This sets the content_type to `text/html`
  macro html(body, status_code = 200)
    context.response.status_code = {{status_code}}
    context.response.content_type = "text/html"
    return {{body}}
  end

  # helper to render json.  This sets the content_type to `application/json`
  macro json(body, status_code = 200)
    context.response.status_code = {{status_code}}
    context.response.content_type = "application/json"
    return {{body}}
  end
end
