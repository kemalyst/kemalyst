# require "../models/demo"

# module DemoController
#   # WARNING: Do not store state in this module unless you
#   # protect it with mutexes since each class below can be 
#   # called from different fibers.
  
#   class Index < Kemalyst::Controller
#     def call(context)
#       demos = Demo.all
#       render "demo/index.ecr", "main.ecr"
#     end
#   end

#   class Show < Kemalyst::Controller
#     def call(context)
#       id = context.params["id"]
#       if demo = Demo.find id
#         render "demo/show.ecr", "main.ecr"
#       else
#         text "Demo with id:#{id} could not be found", 404
#       end
#     end
#   end

#   class New < Kemalyst::Controller
#     def call(context)
#       render "demo/new.ecr", "main.ecr"
#     end
#   end

#   class Create < Kemalyst::Controller
#     def call(context)
#       if demo = Demo.new
#         demo.name = context.params["name"] as String
#         demo.save()
#       end
#       if id = demo.id
#         redirect "/demos"
#       else
#         text "Could not create Demo.", 400
#       end
#     end
#   end

#   class Edit < Kemalyst::Controller
#     def call(context)
#       id = context.params["id"]
#       if demo = Demo.find id
#         render "demo/edit.ecr", "main.ecr"
#       else
#         text "Demo with id:#{id} could not be found", 404
#       end
#     end
#   end

#   class Update < Kemalyst::Controller
#     def call(context)
#       id = context.params["id"]
#       if demo = Demo.find id 
#         demo.name = context.params["name"] as String
#         demo.save
#       else
#         text "Demo with id:#{id} could not be found", 404
#       end
#       redirect "/demos"
#     end
#   end

#   class Delete < Kemalyst::Controller
#     def call(context)
#       id = context.params["id"]
#       if demo = Demo.find id
#         demo.destroy
#       else
#         text "Demo with id:#{id} could not be found", 404
#       end
#       redirect "/demos"
#     end
#   end

# end
