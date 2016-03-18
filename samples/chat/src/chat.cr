require "../../../src/kemalyst"
require "../config/*"

class Chat::Application < Kemalyst::Application
end

Chat::Application.instance.start
