require "../app/controllers/*"

  
  get "/" do |context| 
    PostController.index(context)
  end

  get "/posts" do |context| 
    PostController.index(context)
  end

  get "/posts/:id" do |context| 
    PostController.show(context)
  end

  get "/posts/new" do |context| 
    PostController.new(context)
  end

  post  "/posts/create" do |context| 
    PostController.create(context)
  end
  
  get  "/posts/:id/edit" do |context| 
    PostController.edit(context)
  end
  
  post "/posts/:id/update" do |context| 
    PostController.update(context)
  end

  post "/posts/:id/delete" do |context| 
    PostController.delete(context)
  end

