require "../../../src/kemalyst"
require "../config/*"

class Blog::Application < Kemalyst::Application
end

Blog::Application.instance.start
