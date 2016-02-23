module Kemalyst
  class Controller
    
    macro render(filename, layout)
      content = render {{filename}}
      render "layouts/{{layout.id}}"
    end

    macro render(filename, *args)
      Kilt.render("app/views/{{filename.id}}", {{*args}})
    end
   
  end
end

