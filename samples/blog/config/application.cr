Kemalyst::Blog::Application.config do |config|
  
  log = File("logs/development.log", "a")
  log.write_on_flush = true

  # using the built-in logger. you can create your own.
  config.logger = Logger.new(log)
  config.logger.level = Logger::DEBUG


end
