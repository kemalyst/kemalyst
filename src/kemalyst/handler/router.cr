require "http/server"
require "delimiter_tree"

module Kemalyst::Handler
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
  # get "/", [ BasicAuth.instance("username", "password"), 
  #            DemoController::Index.instance ]
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
  # get "/", [ WebSocket.instance(ChatController::Chat.instance),
  #            ChatController::Index.instance ]
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
  # all    "/posts/*",   BasicAuth.instance("admin", "password")
  #
  # # all of these will be secured with the BasicAuth handler.
  # get    "/posts/:id", DemoController::Show.instance
  # put    "/posts/:id", DemoController::Update.instance
  # delete "/posts/:id", DemoController::Delete.instance
  # ```
  # You can use `:variable` in the path and it will set a
  # context.params["variable"] to the value in the url.
  class Router < Base
    property tree : Delimiter::Tree(Nil | Kemalyst::Handler::Route)

    HTTP_METHODS = %w(get post put patch delete)

    {% for method in HTTP_METHODS %}
      def self.{{method.id}}(path, &block : HTTP::Server::Context -> _)
        handler = Kemalyst::Handler::Block.new(block)
        Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handler)
      end
      def self.{{method.id}}(path, handler : HTTP::Handler)
        Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handler)
      end
      def self.{{method.id}}(path, handler : HTTP::Handler, &block : HTTP::Server::Context -> _)
        handler = Kemalyst::Handler::Block.new(block)
        Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, [handler, handler])
      end
      def self.{{method.id}}(path, handlers : Array(HTTP::Handler))
        Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handlers)
      end
      def self.{{method.id}}(path, handlers : Array(HTTP::Handler), &block : HTTP::Server::Context -> _)
        handlers << Kemalyst::Handler::Block.new(block)
        Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handlers)
      end
    {% end %}

    def self.all(path, handler : HTTP::Handler)
      self.get path, handler
      self.put path, handler
      self.post path, handler
      self.patch path, handler
      self.delete path, handler
    end

    def initialize
      @tree = Delimiter::Tree(Nil | Kemalyst::Handler::Route).new
    end

    def call(context)
      context.response.content_type = "text/html"
      process_request(context)
    end

    # Adds a given route to routing tree. As an exception each `GET` route additionaly defines
    # a corresponding `HEAD` route.
    def add_route(method, path, handler)
      add_to_tree method, path, Route.new(method, path, handler)
      add_to_tree("HEAD", path, Route.new("HEAD", path, handler)) if method == "GET"
    end

    def add_route(method, path,  handlers : Array(HTTP::Handler))
      raise ArgumentError.new "You must specify at least one HTTP Handler." if handlers.empty?
      0.upto(handlers.size - 2) { |i| handlers[i].next = handlers[i + 1] }
      add_route(method, path, handlers.first)
    end

    # Check if a route is defined and returns the lookup
    def lookup_route(verb, path)
      @tree.find delimiter_path(verb, path)
    end

    # Processes the route if it's a match. Otherwise renders 404.
    def process_request(context)
      method = context.request.method
      # Is there an overrided _method parameter?
      method = context.params["_method"] if context.params.has_key? "_method"
      result = lookup_route(method as String, context.request.path)
      if result.found?
        if routes = result.payload
          # Add routing params to context.params
          result.params.each do |key, value|
            context.params[key] = value
          end
          
          # chain the routes
          0.upto(routes.size - 2) do |i|
            if route = routes[i]
              if next_route = routes[i + 1]
                route.handler.next = next_route.handler
              end
            end
          end
          
          if route = routes.first
            if content = route.handler.call(context) as String
              context.response.print(content)
            end
          end
        else
          raise Kemalyst::Exceptions::RouteNotFound.new("Requested payload: '#{method as String}:#{context.request.path}' was not found.")
        end
      else
        raise Kemalyst::Exceptions::RouteNotFound.new("Requested path: '#{method as String}:#{context.request.path}' was not found.")
      end
      context
    end
    
    private def delimiter_path(method : String, path)
      "#{method.downcase}/#{path}"
    end

    private def add_to_tree(method, path, route)
      node = delimiter_path(method, path)
      @tree.add(node, route)
    end

  end
end

