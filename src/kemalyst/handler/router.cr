require "http/server"
require "radix"

HTTP_METHODS = %w(get post put patch delete)

{% for method in HTTP_METHODS %}
  def {{method.id}}(path, &block : HTTP::Server::Context -> _)
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, block)
  end
  def {{method.id}}(path, handler : HTTP::Handler)
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handler)
  end
  def {{method.id}}(path, handler : HTTP::Handler, &block : HTTP::Server::Context -> _)
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, [handler], block)
  end
  def {{method.id}}(path, handlers : Array(HTTP::Handler))
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handlers)
  end
  def {{method.id}}(path, handlers : Array(HTTP::Handler), &block : HTTP::Server::Context -> _)
    Kemalyst::Handler::Router.instance.add_route({{method}}.upcase, path, handlers, block)
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
    def add_route(method, path, handler)
      add_to_radix_tree method, path, Route.new(method, path, handler)
      add_to_radix_tree("HEAD", path, Route.new("HEAD", path, handler)) if method == "GET"
    end

    def add_route(method, path,  handlers : Array(HTTP::Handler), last_handler = nil : HTTP::Server::Context -> _)
      raise ArgumentError.new "You must specify at least one HTTP Handler." if handlers.empty?
      0.upto(handlers.size - 2) { |i| handlers[i].next = handlers[i + 1] }
      handlers.last.next = last_handler if last_handler
      add_route(method, path, handlers.first)
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
        context.params[key.gsub("/", "")] = value
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

