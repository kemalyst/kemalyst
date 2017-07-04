module Kemalyst::Helpers
  # Helper method to get the logger
  def logger
    Kemalyst::Application.instance.logger
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
  macro render(filename, layout, *args)
    content = render("{{filename.id}}", {{ *args }})
    render("layouts/{{layout.id}}")
  end

  # helper to render a template.  The view name is relative to `src/views` directory.
  macro render(filename, *args)
    Kilt.render("src/views/{{filename.id}}", {{ *args }})
  end

  # helper to redirect to another page.  This sets the Location header to
  # the url provided.
  macro redirect(url, status_code = 302)
    context.response.status_code = {{ status_code }}
    context.response.headers.add("Location", {{ url }})
  end

  # helper to render text.  This sets the content_type to `plain/text`
  macro text(body, status_code = 200)
    context.response.status_code = {{ status_code }}
    context.response.content_type = "text/plain"
    context.response.print({{ body }})
  end

  # helper to render html.  This sets the content_type to `text/html`
  macro html(body, status_code = 200)
    context.response.status_code = {{ status_code }}
    context.response.content_type = "text/html; charset=UTF-8"
    context.response.print({{ body }})
  end

  # helper to render json.  This sets the content_type to `application/json`
  macro json(body, status_code = 200)
    context.response.status_code = {{ status_code }}
    context.response.content_type = "application/json"
    context.response.print({{ body }})
  end

  # helper to render xml.  This sets the content_type to `application/xml`
  macro xml(body, status_code = 200)
    context.response.status_code = {{ status_code }}
    context.response.content_type = "application/xml"
    context.response.print({{ body }})
  end
end
