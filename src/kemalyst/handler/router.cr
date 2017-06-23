require "http/server"
require "radix"

module Kemalyst::Handler
  HTTP_METHODS = %w(get post put patch delete)

  {% for method in HTTP_METHODS %}
    def {{method.id}}(path, &block : HTTP::Server::Context -> _)
      handler = Block.new(block)
      Router.instance.add_route({{method}}.upcase, path, handler)
    end
    def {{method.id}}(path, handler : HTTP::Handler)
      Router.instance.add_route({{method}}.upcase, path, handler)
    end
    def {{method.id}}(path, handler : HTTP::Handler.class)
      Router.instance.add_route({{method}}.upcase, path, handler.new)
    end
  {% end %}

  def all(path, handler : HTTP::Handler)
    get path, handler
    post path, handler
    patch path, handler
    delete path, handler
  end

  macro get(path, controller, action)
    get("{{ path.id }}") do |context|
      controller = {{ controller.id.capitalize }}Controller.new(context)
      controller.run_before_filter(:all)
      controller.run_before_filter(:{{ action.id }})
      controller.{{ action.id }}
      controller.run_after_filter(:{{ action.id }})
      controller.run_after_filter(:all)
    end
  end

  macro post(path, controller, action)
    post("{{ path.id }}") do |context|
      controller = {{ controller.id.capitalize }}Controller.new(context)
      controller.run_before_filter(:all)
      controller.run_before_filter(:{{ action.id }})
      controller.{{ action.id }}
      controller.run_after_filter(:{{ action.id }})
      controller.run_after_filter(:all)
    end
  end

  macro patch(path, controller, action)
    patch("{{ path.id }}") do |context|
      controller = {{ controller.id.capitalize }}Controller.new(context)
      controller.run_before_filter(:all)
      controller.run_before_filter(:{{ action.id }})
      controller.{{ action.id }}
      controller.run_after_filter(:{{ action.id }})
      controller.run_after_filter(:all)
    end
  end

  macro delete(path, controller, action)
    delete("{{ path.id }}") do |context|
      controller = {{ controller.id.capitalize }}Controller.new(context)
      controller.run_before_filter(:all)
      controller.run_before_filter(:{{ action.id }})
      controller.{{ action.id }}
      controller.run_after_filter(:{{ action.id }})
      controller.run_after_filter(:all)
    end
  end

  macro resources(name)
    get "/{{name.id.downcase}}s", "{{name.id.capitalize}}", "index"
    get "/{{name.id.downcase}}s/new", "{{name.id.capitalize}}", "new"
    post "/{{name.id.downcase}}s", "{{name.id.capitalize}}", "create"
    get "/{{name.id.downcase}}s/:id", "{{name.id.capitalize}}", "show"
    get "/{{name.id.downcase}}s/:id/edit", "{{name.id.capitalize}}", "edit"
    patch "/{{name.id.downcase}}s/:id", "{{name.id.capitalize}}", "update"
    delete "/{{name.id.downcase}}s/:id", "{{name.id.capitalize}}", "delete"
  end

  macro resource(name)
    get "/{{name.id.downcase}}/new", "{{name.id.capitalize}}", "new"
    post "/{{name.id.downcase}}", "{{name.id.capitalize}}", "create"
    get "/{{name.id.downcase}}", "{{name.id.capitalize}}", "show"
    get "/{{name.id.downcase}}/edit", "{{name.id.capitalize}}", "update"
    patch "/{{name.id.downcase}}", "{{name.id.capitalize}}", "update"
    delete "/{{name.id.downcase}}", "{{name.id.capitalize}}", "delete"
  end

  # The Route holds the information for the node in the tree.
  class Route
    getter method
    getter path
    getter handler

    def initialize(@method : String, @path : String, @handler : HTTP::Handler)
    end
  end

  # The Router Handler redirects traffic to the appropriate Handlers based on
  # the path and method provided.  This allows for filtering which handlers should
  # be accessed.  Several macros are provided to help with registering the
  # path and method handlers.  Routes should be defined in the
  # `config/routes.cr` file.
  class Router < Base
    property tree : Radix::Tree(Kemalyst::Handler::Route)

    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def initialize
      @tree = Radix::Tree(Kemalyst::Handler::Route).new
    end

    def call(context)
      process_request(context)
    end

    # Processes the route if it's a match. Otherwise renders 404.
    def process_request(context)
      method = context.request.method
      result = lookup_route(method.as(String), context.request.path)
      if result.found?
        if route = result.payload
          # Add routing params to context.params
          result.params.each do |key, value|
            context.params[key] = value
          end
          route.handler.call(context)
        else
          call_next context
        end
      else
        call_next context
      end
    end

    # Adds a given route to routing tree. As an exception each `GET` route additionaly defines
    # a corresponding `HEAD` route.
    def add_route(method, path, handler)
      add_to_tree(method, path, Route.new(method, path, handler))
      add_to_tree("HEAD", path, Route.new("HEAD", path, handler)) if method == "GET"
    end

    # Check if a route is defined and returns the lookup
    def lookup_route(verb, path)
      @tree.find method_path(verb, path)
    end

    private def add_to_tree(method, path, route)
      node = method_path(method, path)
      result = @tree.find(node)
      if result && result.found?
        result.payload.handler.next = route.handler
      else
        @tree.add(node, route)
      end
    end

    private def method_path(method : String, path)
      "#{method.downcase}/#{path}"
    end
  end
end
