require "kilt"
require "../models/post"



class PostController < Kemalyst::Controller

  def self.index(context)
    posts = Post.all("ORDER BY created_at DESC")
    render "post/index.ecr", "layout.ecr"
  end

  def self.show(context)
    id = context.params["id"]
   
    post = Post.find(id) 
    render "post/show.ecr", "layout.ecr"
  end

  def self.new(context)
    render "post/new.ecr", "layout.ecr"
  end

  def self.create(context)
    if post = Post.new
      post.name = context.params["name"]
      post.body = context.params["body"]
      post.save
    end
    context.redirect "/posts"
    return context
  end

  def self.edit(context)
    id = context.params["id"]
    
    post = Post.find(id) 
    render "post/edit.ecr", "layout.ecr"
  end

  def self.update(context)
    id = context.params["id"]
    if post = Post.find(id)
      post.name = context.params["name"]
      post.body = context.params["body"]
      post.save
    end
    context.redirect "/posts/#{id}"
    return context
  end

  def self.delete(context)
    id = context.params["id"]
    if post = Post.find(id)
      post.destroy
    end
    context.redirect "/posts"
    return context
  end

end

