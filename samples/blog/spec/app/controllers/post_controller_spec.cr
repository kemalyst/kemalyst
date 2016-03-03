require "./spec_helper"

Mocks.create_mock Post do
  mock self.all(query), :inherited
  mock self.find(id), :inherited
  mock save(), :inherited
  mock destroy(), :inherited
end

describe PostController::Index do

  it "renders all the posts" do
    sample_post = Post.new
    sample_post.name = "sample post"
    allow(Post).to receive(self.all("ORDER BY created_at DESC")).and_return([sample_post])

    request = HTTP::Request.new("GET", "/posts")
    io, context = create_context(request) 
    PostController::Index.instance.call(context)
    context.response.close
    io.rewind
    response = HTTP::Client::Response.from_io(io)
    response.body.should contain "sample post"
  end

end

describe PostController::Show do

  it "shows a single post" do
    sample_post = Post.new
    sample_post.name = "sample post"
    allow(Post).to receive(self.find("1")).and_return(sample_post)

    request = HTTP::Request.new("GET", "/posts/1")
    io, context = create_context(request) 
    context.params["id"] = "1"
    PostController::Show.instance.call(context)
    context.response.close
    io.rewind
    response = HTTP::Client::Response.from_io(io)
    response.body.should contain "sample post"
  end

end

describe PostController::New do

  it "displays form to create a new post when authorized" do
    request = HTTP::Request.new("GET", "/posts/new")
    io, context = create_context(request) 
    context.session["authorized"] = "true"
    PostController::New.instance.call(context)
    context.response.close
    io.rewind
    response = HTTP::Client::Response.from_io(io)
    response.body.should contain "<h1>New Post</h1>"
  end

end

describe PostController::Create do

  it "creates a new post when authorized" do
    request = HTTP::Request.new("POST", "/posts/create")
    io, context = create_context(request) 
    context.session["authorized"] = "true"
    context.params["name"] = "new post"
    context.params["body"] = "new post body"

    #allow(post).to receive(save()).and_return(true)

    # PostController::Create.instance.call(context)
    # context.response.close
    # io.rewind
    # response = HTTP::Client::Response.from_io(io)
    # response.headers["Location"].should contain "/posts"
  end

end

describe PostController::Edit do

  it "displays form to edit an existing post" do
    sample_post = Post.new
    sample_post.name = "sample post"
    allow(Post).to receive(self.find("1")).and_return(sample_post)

    request = HTTP::Request.new("GET", "/posts/1/edit")
    io, context = create_context(request) 
    context.session["authorized"] = "true"
    context.params["id"] = "1"
    PostController::Edit.instance.call(context)
    context.response.close
    io.rewind
    response = HTTP::Client::Response.from_io(io)
    response.body.should contain "<h1>Edit Post</h1>"
  end

end

describe PostController::Update do

  it "updates an existing post" do
  end

end

describe PostController::Delete do

  it "destroys an existing post" do
  end

end
