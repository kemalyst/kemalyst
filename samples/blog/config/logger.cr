Kemalyst::Handler::Logger.config do |config|
  config.filename = "logs/#{Kemalyst::Blog::Application.instance.env}.log"
end
