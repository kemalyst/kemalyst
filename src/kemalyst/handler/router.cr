require "http/server"
require "delimiter_tree"

HTTP_METHODS = %w(get post put patch delete options)

{% for method in HTTP_METHODS %}
  def {{method.id}}(path, &block : HTTP::Server::Context -> _)
    handler = Kemalyst::Handler::Block.new(block)
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handler)
  end
  def {{method.id}}(path, handler : HTTP::Handler)
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handler)
  end
  def {{method.id}}(path, handler : HTTP::Handler, &block : HTTP::Server::Context -> _)
    handler = Kemalyst::Handler::Block.new(block)
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, [handler, handler])
  end
  def {{method.id}}(path, handlers : Array(HTTP::Handler))
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handlers)
  end
  def {{method.id}}(path, handlers : Array(HTTP::Handler), &block : HTTP::Server::Context -> _)
    handlers << Kemalyst::Handler::Block.new(block)
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handlers)
  end
{% end %}

module Kemalyst::Handler
  
  class Router < Base

    def initialize
      @tree = Delimiter::Tree(Nil | Kemalyst::Route).new
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
      @tree.find radix_path(verb, path)
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
    
    private def radix_path(method : String, path)
      "#{method.downcase}/#{path}"
    end

    private def add_to_tree(method, path, route)
      node = radix_path(method, path)
      @tree.add(node, route)
    end

  end
end

