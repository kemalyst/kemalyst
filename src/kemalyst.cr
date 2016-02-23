require "./kemalyst/*"
require "http"
require "option_parser"
require "./kemalyst/handler/*"
include Kemalyst::Handler

module Kemalyst
  class Application
    property host, port, env, handlers

    def self.instance
      @@instance ||= new
    end

    def initialize
      @host = "0.0.0.0"
      @port = 3000
      @env = "development"
      @handlers = [] of HTTP::Handler
      parse_command_line_options
    end

    # Handlers are processed in order. Each handler has their own configuration file.
    def setup_handlers
      @handlers << Logger.instance
      @handlers << Error.instance
      @handlers << Static.instance
      @handlers << Session.instance
      @handlers << Params.instance
      @handlers << Router.instance
    end

    def run
      setup_handlers
      server = HTTP::Server.new(@host.to_slice, @port, @handlers)

      Signal::INT.trap {
        server.close
        exit
      }

      puts "Server started on #{@host}:#{@port} in #{@env}."
      server.listen
    end

    private def parse_command_line_options
      OptionParser.parse! do |opts|
        opts.on("-h HOST", "--host HOST", "Host to bind (defaults to
                0.0.0.0)") do |opt_host|
          @host = opt_host
        end
        opts.on("-p PORT", "--port PORT", "Port to listen for connections (defaults to 3000)") do |opt_port|
          @port = opt_port.to_i
        end
        opts.on("-e ENV", "--environment ENV", "Environment [development,
         production] (defaults to development).") do |opt_env|
          @env = opt_env
        end
      end
    end
  end
end
