Kemalyst::Application.config do |config|
  config.env = "production"
  
  # create a log file
  log = File.new("logs/#{config.env}.log", "a")
  log.flush_on_newline = true

  # create a logger. you can create your own custom logger.
  config.logger = Logger.new(log)
  config.logger.level = Logger::DEBUG

  # creating a formatter.  This overrides the default crystal formatter
  config.logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
    io << "[" << datetime << " #" << Process.pid << "] "
    io << severity.rjust(5) << ": " << message
  end

end
