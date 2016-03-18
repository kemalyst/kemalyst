require "../models/post"
include Kemalyst

module PostController
  
  class Index < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      posts = Post.all("ORDER BY created_at DESC")
      render "post/index.ecr", "main.ecr"
    end
  end

  class Show < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      id = context.params["id"]
      post = Post.find(id)
      if post
        render "post/show.ecr", "main.ecr"
      else
        text "Post with id:#{id} could not be found", 404
      end
    end
  end

  class New < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      if authorized
        render "post/new.ecr", "main.ecr"
      else
        redirect "/posts"
      end
    end
  end

  class Create < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      if authorized
        if post = Post.new
          post.name = context.params["name"]
          post.body = context.params["body"]
          post.save()
        end
      end
      redirect "/posts"
    end
  end

  class Edit < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      if authorized
        id = context.params["id"]
        post = Post.find(id)
        if post
          render "post/edit.ecr", "main.ecr"
        else
          text "Post with id:#{id} could not be found", 404
        end
      else
        redirect "/posts"
      end
    end
  end

  class Update < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      if authorized
        id = context.params["id"]
        if post = ::Post.find(id)
          post.name = context.params["name"]
          post.body = context.params["body"]
          post.save
        else
          text "Post with id:#{id} could not be found", 404
        end
        redirect "/posts/#{id}"
      else
        redirect "/posts"
      end
    end
  end

  class Delete < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      if authorized
        id = context.params["id"]
        if post = ::Post.find(id)
          post.destroy
        else
          text "Post with id:#{id} could not be found", 404
        end
      end
      redirect "/posts"
    end
  end

end

