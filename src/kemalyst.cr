require "http"
require "option_parser"
require "logger"
require "crack"
require "./kemalyst/*"
require "./kemalyst/handler/*"

module Kemalyst
  # The `Application` handles the starting of the server.  There are several
  # properties that can be configured.  The `host` is the binding ip address.
  # The `port` is the tcp/ip port that this server will listen on.  The `env`
  # can be used to reconfigure the handlers.  For example, you may want a
  # different logger based on the environment.  The `logger` is an application
  # wide logger.  The `handlers` is the list of handlers used by this server.
  # You can add other custom handlers other than the ones provided.
  class Application
    property host, port, env, logger, handlers, reuse_port

    # Singleton that will return the single instance of the Application.
    def self.instance
      @@instance ||= new
    end

    # You can configure the application using this method.  It's recommended
    # to create a `config/application.cr` that will provide you the ability to
    # configure your application.
    def self.config
      yield self.instance
    end

    # You can configure the instance itself.
    def config
      yield self
    end

    def initialize
      @host = "0.0.0.0"
      @port = 3000
      @env = "development"
      @logger = Logger.new(STDOUT)
      @handlers = [] of HTTP::Handler
      @reuse_port = false

      parse_command_line_options
    end

    # Start the server.  This is what will get everything going.
    def start
      setup_handlers
      server = HTTP::Server.new(@host, @port, @handlers)
      server.bind(@reuse_port)

      Signal::INT.trap {
        server.close
        exit
      }

      puts "Reuse port enabled." if @reuse_port
      puts "Server started on #{@host}:#{@port} in #{@env}."
      server.listen
    end

    # Handlers are processed in order. Each handler has their own configuration file.
    def setup_handlers
      # only setup handlers if they haven't been setup yet
      if @handlers.empty?
        @handlers << Crack::Handler::Logger.instance(@logger)
        @handlers << Crack::Handler::Error.instance
        @handlers << Crack::Handler::Static.instance
        @handlers << Crack::Handler::Session.instance
        @handlers << Crack::Handler::Flash.instance
        @handlers << Crack::Handler::Params.instance
        @handlers << Crack::Handler::Method.instance
        @handlers << Crack::Handler::CSRF.instance
        @handlers << Kemalyst::Handler::Router.instance
      end
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
        opts.on("--reuse_port", "Enable reuse port") do
          @reuse_port = true
        end
      end
    end
  end
end
