require "http/server"
require "radix"

HTTP_METHODS = %w(get post put patch delete)

{% for method in HTTP_METHODS %}
  def {{method.id}}(path, &block : HTTP::Server::Context -> _)
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, &block)
  end
{% end %}


module Kemalyst::Handler
  class Router < Base
 
    def initialize
      @tree = Radix::Tree.new
    end

    def call(context)
      context.response.content_type = "text/html"
      process_request(context)
    end

    # Adds a given route to routing tree. As an exception each `GET` route additionaly defines
    # a corresponding `HEAD` route.
    def add_route(method, path, &handler : HTTP::Server::Context -> _)
      add_to_radix_tree method, path, Route.new(method, path, &handler)
      add_to_radix_tree("HEAD", path, Route.new("HEAD", path, &handler)) if method == "GET"
    end

    # Check if a route is defined and returns the lookup
    def lookup_route(verb, path)
      @tree.find radix_path(verb, path)
    end

    # Processes the route if it's a match. Otherwise renders 404.
    def process_request(context)
      node = lookup_route(context.request.method as String, context.request.path)
      route = node.payload as Route
      node.params.each do |key, value|
        context.params[key] = value
      end
      context.response.print(route.handler.call(context).to_s)
      context
    end
    
    private def radix_path(method : String, path)
      "/#{method.downcase}#{path}"
    end

    private def add_to_radix_tree(method, path, route)
      node = radix_path(method, path)
      @tree.add(node, route)
    end

  end
end

