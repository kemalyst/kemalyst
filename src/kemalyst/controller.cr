require "http"
require "kilt"

module Kemalyst
  class Controller < HTTP::Handler

    def self.instance
      @@instance ||= new
    end

    def call(context)
      call_next context
    end

    macro render(filename, layout)
      content = render {{filename}}
      render "layouts/{{layout.id}}"
    end

    macro render(filename, *args)
      Kilt.render("app/views/{{filename.id}}", {{*args}})
    end
   
  end
end

