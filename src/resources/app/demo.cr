require "kemalyst"
require "../config/*"

class Demo::Application < Kemalyst::Application
end

Demo::Application.instance.start
