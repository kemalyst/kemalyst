require "../../../src/kemalyst"
require "../config/routes"

module Kemalyst::Blog
  class Application < Kemalyst::Application
  end
end

Kemalyst::Blog::Application.instance.run
