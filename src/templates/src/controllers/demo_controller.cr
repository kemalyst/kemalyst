require "../models/demo"

module DemoController
 class Index < Kemalyst::Controller
    def call(context)
      demos = Demo.all
      render "demo/index.ecr", "main.ecr"
    end
  end

  class Show < Kemalyst::Controller
    def call(context)
      id = context.params["id"]
      if demo = Demo.find id
        render "demo/show.ecr", "main.ecr"
      else
        redirect "/demos"
      end
    end
  end

  class New < Kemalyst::Controller
    def call(context)
      demo = Demo.new
      render "demo/new.ecr", "main.ecr"
    end
  end

  class Create < Kemalyst::Controller
    def call(context)
      demo = Demo.new
      demo.name = context.params["name"].as(String)
      if demo.save
        redirect "/demos"
      else
        render "demo/new.ecr", "main.ecr"
      end
    end
  end

  class Edit < Kemalyst::Controller
    def call(context)
      id = context.params["id"]
      if demo = Demo.find id
        render "demo/edit.ecr", "main.ecr"
      else
        redirect "/demos"
      end
    end
  end

  class Update < Kemalyst::Controller
    def call(context)
      id = context.params["id"]
      if demo = Demo.find id
        demo.name = context.params["name"].as(String)
        if demo.save
          redirect "/demos"
        else
          render "demo/edit.ecr", "main.ecr"
        end
      else
        redirect "/demos"
      end
    end
  end

  class Delete < Kemalyst::Controller
    def call(context)
      id = context.params["id"]
      if demo = Demo.find id
        demo.destroy
      end
      redirect "/demos"
    end
  end

end
