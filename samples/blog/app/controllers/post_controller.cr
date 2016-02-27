require "../models/post"
include Kemalyst

module PostController
  
  class Index < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      posts = ::Post.all("ORDER BY created_at DESC")
      render "post/index.ecr", "layout.ecr"
    end
  end

  class Show < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      id = context.params["id"]
      post = ::Post.find(id) 
      render "post/show.ecr", "layout.ecr"
    end
  end

  class New < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      if authorized
        render "post/new.ecr", "layout.ecr"
      else
        context.redirect "/posts"
        return ""
      end
    end
  end

  class Create < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      if authorized
        if post = ::Post.new
          post.name = context.params["name"]
          post.body = context.params["body"]
          post.save
        end
      end
      context.redirect "/posts"
      return ""
    end
  end

  class Edit < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      if authorized
        id = context.params["id"]
        post = ::Post.find(id) 
        render "post/edit.ecr", "layout.ecr"
      else
        context.redirect "/posts"
        return ""
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
        end
        context.redirect "/posts/#{id}"
      else
        context.redirect "/posts"
      end
      return ""
    end
  end

  class Delete < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      if authorized
        id = context.params["id"]
        if post = ::Post.find(id)
          post.destroy
        end
      end
      context.redirect "/posts"
      return ""
    end
  end

end

