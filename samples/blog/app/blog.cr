require "../../../src/kemalyst"
require "../config/*"

module Kemalyst::Blog
  class Application < Kemalyst::Application

    def initialize
      super
      @env = "development"
    end

  end
end

Kemalyst::Blog::Application.instance.start
