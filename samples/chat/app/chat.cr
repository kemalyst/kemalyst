require "../../../src/kemalyst"
require "../config/routes"

module Kemalyst::Chat
  class Application < Kemalyst::Application
  end
end

Kemalyst::Chat::Application.instance.start
