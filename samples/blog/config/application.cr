Kemalyst::Blog::Application.config do |config|
  
  log = File.new("logs/development.log", "a")
  log.flush_on_newline = true

  # using the built-in logger. you can create your own.
  config.logger = Logger.new(log)
  config.logger.level = Logger::DEBUG
  config.logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
    io << "[" << datetime << " #" << Process.pid << "] "
    io << severity.rjust(5) << ": " << message
  end

end
