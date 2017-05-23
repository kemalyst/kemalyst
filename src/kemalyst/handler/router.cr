require "http/server"
require "radix"

module Kemalyst::Handler
  HTTP_METHODS = %w(get post patch delete)

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
    def {{method.id}}(path, handlers : Array(HTTP::Handler))
      handlers.each do |handler|
        Router.instance.add_route({{method}}.upcase, path, handler)
      end
    end
    def {{method.id}}(path, handlers : Array(HTTP::Handler.class))
      handlers.each do |handler|
        Router.instance.add_route({{method}}.upcase, path, handler.new)
      end
    end
  {% end %}

  def all(path, handler : HTTP::Handler)
    get path, handler
    post path, handler
    patch path, handler
    delete path, handler
  end

  macro get(path, controller, action)
    Router.instance.add_route "get", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  macro post(path, controller, action)
    Router.instance.add_route "post", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  macro patch(path, controller, action)
    Router.instance.add_route "patch", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  macro delete(path, controller, action)
    Router.instance.add_route "delete", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  macro all(path, controller, action)
    Router.instance.add_route "get", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.add_route "post", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.add_route "patch", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.add_route "delete", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  macro before_get(path, controller, action)
    Router.instance.before_route "get", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  macro before_post(path, controller, action)
    Router.instance.before_route "post", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  macro before_patch(path, controller, action)
    Router.instance.before_route "patch", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  macro before_delete(path, controller, action)
    Router.instance.before_route "delete", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  macro before_all(path, controller, action)
    Router.instance.before_route "get", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "post", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "patch", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "delete", "{{path.id}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  # The resources macro will create a set of routes for a list of resources endpoint.
  macro resources(name)
    Router.instance.add_route "get", "/{{name.id.downcase}}s", {{name.id.capitalize}}Controller::Index.new
    Router.instance.add_route "get", "/{{name.id.downcase}}s/new", {{name.id.capitalize}}Controller::New.new
    Router.instance.add_route "post", "/{{name.id.downcase}}s", {{name.id.capitalize}}Controller::Create.new
    Router.instance.add_route "get", "/{{name.id.downcase}}s/:id", {{name.id.capitalize}}Controller::Show.new
    Router.instance.add_route "get", "/{{name.id.downcase}}s/:id/edit", {{name.id.capitalize}}Controller::Edit.new
    Router.instance.add_route "patch", "/{{name.id.downcase}}s/:id", {{name.id.capitalize}}Controller::Update.new
    Router.instance.add_route "delete", "/{{name.id.downcase}}s/:id", {{name.id.capitalize}}Controller::Delete.new
  end

  # The resource macro will create a set of routes for a single resource endpoint
  macro resource(name)
    Router.instance.add_route "get", "/{{name.id.downcase}}/new", {{name.id.capitalize}}Controller::New.new
    Router.instance.add_route "post", "/{{name.id.downcase}}", {{name.id.capitalize}}Controller::Create.new
    Router.instance.add_route "get", "/{{name.id.downcase}}", {{name.id.capitalize}}Controller::Show.new
    Router.instance.add_route "get", "/{{name.id.downcase}}/edit", {{name.id.capitalize}}Controller::Edit.new
    Router.instance.add_route "patch", "/{{name.id.downcase}}s/:id", {{name.id.capitalize}}Controller::Update.new
    Router.instance.add_route "delete", "/{{name.id.downcase}}", {{name.id.capitalize}}Controller::Delete.new
  end

  # The resources macro will create a set of routes for a list of resources endpoint.
  macro before_resources(name, controller, action)
    Router.instance.before_route "get", "/{{name.id.downcase}}s", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "get", "/{{name.id.downcase}}s/new", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "post", "/{{name.id.downcase}}s", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "get", "/{{name.id.downcase}}s/:id", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "get", "/{{name.id.downcase}}s/:id/edit", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "patch", "/{{name.id.downcase}}s/:id", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "delete", "/{{name.id.downcase}}s/:id", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
  end

  # The resource macro will create a set of routes for a single resource endpoint
  macro before_resource(name, controller, action)
    Router.instance.before_route "get", "/{{name.id.downcase}}/new", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "post", "/{{name.id.downcase}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "get", "/{{name.id.downcase}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "get", "/{{name.id.downcase}}/edit", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "patch", "/{{name.id.downcase}}s/:id", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
    Router.instance.before_route "delete", "/{{name.id.downcase}}", {{controller.id.capitalize}}Controller::{{action.id.capitalize}}.new
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
  #
  # An example of a route would be:
  # ```
  # get "/", DemoController::Index.instance
  # ```
  #
  # You may also pass in a block similar to sinatra or kemal:
  # ```
  # get "/" do |context|
  #   text "Great job!", 200
  # end
  # ```
  #
  # You may chain multiple handlers in a route using an array:
  # ```
  # get "/", [BasicAuth.instance("username", "password"),
  #           DemoController::Index.instance]
  # ```
  #
  # or:
  # ```
  # get "/", BasicAuth.instance("username", "password") do |context|
  #   text "This is secured by BasicAuth!", 200
  # end
  # ```
  #
  # This is how you would configure a WebSocket:
  # ```
  # get "/", [WebSocket.instance(ChatController::Chat.instance),
  #           ChatController::Index.instance]
  # ```
  #
  # The `Chat` class would have a `call` method that is expecting an
  # `HTTP::WebSocket` to be passed which it would maintain and properly handle
  # messages to and from it.  Check out the sample Chat application to get an idea
  # on how to do this.
  #
  # You can use any of the following methods: `get, post, put, patch, delete, all`
  #
  # You can use a `*` to chain a handler for all children of this path:
  # ```
  # all "/posts/*", BasicAuth.instance("admin", "password")
  #
  # # all of these will be secured with the BasicAuth handler.
  # get "/posts/:id", DemoController::Show.instance
  # put "/posts/:id", DemoController::Update.instance
  # delete "/posts/:id", DemoController::Delete.instance
  # ```
  # You can use `:variable` in the path and it will set a
  # context.params["variable"] to the value in the url.
  class Router < Base
    property tree :  Radix::Tree(Array(Kemalyst::Handler::Route))

    # class method to return a singleton instance of this Controller
    def self.instance
      @@instance ||= new
    end

    def initialize
      @tree = Radix::Tree(Array(Kemalyst::Handler::Route)).new
    end

    def call(context)
      process_request(context)
    end

    # Processes the route if it's a match. Otherwise renders 404.
    def process_request(context)
      method = context.request.method
      result = lookup_route(method.as(String), context.request.path)
      if result.found?
        if routes = result.payload
          # Add routing params to context.params
          result.params.each do |key, value|
            context.params[key] = value
          end

          if route = routes.first
            route.handler.call(context)
          end
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

    def before_route(method, path, handler)
      add_to_tree(method, path, Route.new(method, path, handler))
    end

    # Check if a route is defined and returns the lookup
    def lookup_route(verb, path)
      @tree.find method_path(verb, path)
    end

    private def add_to_tree(method, path, route)
      node = method_path(method, path)
      result = @tree.find(node)
      if result && result.found?
        result.payload.last.handler.next = route.handler
        result.payload << route
      else
        routes = [] of Kemalyst::Handler::Route
        routes << route
        @tree.add(node, routes)
      end
    end

    private def method_path(method : String, path)
      "#{method.downcase}/#{path}"
    end
  end
end
