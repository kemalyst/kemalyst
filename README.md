### WIP (Work In Progress)

[![Build Status](https://travis-ci.org/drujensen/kemalyst.svg?branch=master)](https://travis-ci.org/drujensen/kemalyst)

# Kemalyst

[Kemalyst API documentation](http://kemalyst.drujensen.com) can be found here.

Kemalyst is a yarlf (yet another rails like framework) that is based on on
super fast [kemal](https://github.com/sdogruyol/kemal). The framework
leverages the http handlers which are similar to Rack middleware. The
controllers are also HTTP::Handlers that render the response.  You can chain
handlers in your routes.cr.  For example, you can chain a WebSocket handler
before your Index handler to allow for upgrading the connection for a specific
route.  

The model is a simple ORM mapping and supports MySQL, PG and SQLite.

The views are handled using `ecr` format and several macros to simplify
development.

## Installation

1. Install Crystal

You can find instructions on how to install Crystal from [Crystal's
Website](http://crystal-lang.org).  I recommend using
[crenv](https://github.com/pine613/crenv) to manage your crystal versions.
Currently 0.12.0 is supported.

2. Create a Crystal App

```
crystal init app your_app
cd your_app
```
3. Add kemalyst dependency to your shard.yml
```
dependencies:
  kemalyst:
    github: drujensen/kemalyst
    branch: master
  # optional
  pg:
    github: will/crystal-pg
    branch: master
```
and run `shards update`.

### Post Install

To keep a similar structure to yarlf, several directories and files will be
installed.  This structure should look familiar to you if your coming from a
Rails background.

## Usage

To run the demo app, we are including a Dockerfile and docker-compose.yml. If
you have docker setup, you should be able to run:
```
docker-compose build .
docker-compose run web crystal db/migrate.cr
docker-compose up web
```
This will download an ubuntu/cedar image compatible with heroku and install all the
dependencies including crystal.  It will also include a postgres db image.

Now you should be able to hit the site:
```
open "http://$(docker-machine ip default):3000"
```
You will need to set a secret for the session.  Run the following
command:
```
crystal eval "require \"secure_random\"; puts SecureRandom.hex(64)"
```
copy the secret and set this in `config/session.cr`.

### Configure App

All config settings are in the `/config` folder.  Each handler has its own
settings.  You will find the `database.yml` and `routes.cr` here. Checkout
the samples that demonstrates a traditional blog site and a websocket chat
app.

### Middleware HTTP::Handlers

There are 6 handlers that are pre-configured for Kemalyst:
 - Logger.instance(@logger) - Logs all requests/responses to the `@logger` provided
 - Error.instance - Handles any Exceptions and renders a response.
 - Static.instance - Delivers any static assets from the `./public` folder.
 - Session.instance - Provides a Cookie Session that can be accessed from the
   `context.session`
 - Params.instance - Unifies the parameters into `context.params`
 - Router.instance - Routes requests to other handlers\controllers based on the HTTP method and path.

You may want to add, replace or remove handlers based on your situation.  You can do that in the
Application configuration `config/application.cr`:

```
Kemalyst::Application.config do |config|
  # handlers will be chained in the order provided
  config.handlers = [
    Kemalyst::Handler::Logger.instance(config.logger),
    Kemalyst::Handler::Error.instance,
    # Disable Static and Session handler since this is a REST Service
    # Kemalyst::Handler::Static.instance,
    # Kemalyst::Handler::Session.instance,
    Kemalyst::Handler::Params.instance,
    Kemalyst::Handler::Router.instance
  ]
end
```

### Router

The router will perform a lookup based on the method and path and return the
chain of handlers you specify in the routes.cr file.

An example of a route would be:
```
get "/", DemoController::Index.instance
```

You may also pass in a block similar to sinatra or kemal:
```
get "/" do |context|
  text "Great job!", 200
end
```

You may chain multiple handlers in a route using an array:
```
get "/", [ BasicAuth.instance("username", "password"), 
           DemoController::Index.instance ]
```

or:
```
get "/", BasicAuth.instance("username", "password") do |context|
  text "This is secured by BasicAuth!", 200
end
```

This is how you would configure a WebSocket:
```
get "/", [ WebSocket.instance(ChatController::Chat.instance),
           ChatController::Index.instance ]
```

The `Chat` class would have a `call` method that is expecting an
`HTTP::WebSocket` to be passed which it would maintain and properly handle
messages to and from it.  Check out the sample Chat application to get an idea
on how to do this.

You can use any of the following methods: `get, post, put, patch, delete, all`

You can use a `*` to chain a handler for all children of this path:
```
all    "/posts/*",   BasicAuth.instance("admin", "password")

# all of these will be secured with the BasicAuth handler.
get    "/posts/:id", DemoController::Show.instance
put    "/posts/:id", DemoController::Update.instance
delete "/posts/:id", DemoController::Delete.instance

```
You can use `:variable` in the path and it will set a
context.params["variable"] to the value in the url.

### Controllers

The Controller inherits from HTTP::Handler which is the middleware similar to
Rack's middleware.  The handlers are chained together in a linked-list and
each will perform some action against the HTTP::Server::Context and then call
the next handler in the chain.  The router will continue this chain for a
specific route.  The final handler should return the String that will be
rendered as the body and then the chain will unwind and perform post handling.


An example of a controller:
```
require "../models/post"

class Index < Kemalyst::Controller
  def call(context)
    posts = Post.all("ORDER BY created_at DESC")
    render "post/index.ecr", "main.ecr"
  end
end
```

There are several helper macros that set content type and response.  
```
  render "filename.ecr" # renders an .ecr template
  render "filename.ecr", "layout.ecr" # renders an .ecr template with layout
  redirect "path" # redirect to path
  text "body", 200 #render text/plain response with status code of 200
  json "{}".to_json, 200 #render application/json with status code of 200
  html "<html></html>", 200 #render text/html with status code of 200
```

### Views

Views are rendered using ECR format.  This is similar to Rails ERB.

The render method is configured to look in the "src/views" path to keep the
controllers simple.  You may also render with a layout which will look for
this in the "src/views/layouts" directory.

```
render "post/index.ecr", "main.ecr" 

```
This will render the index.ecr template inside the main.ecr layout. All local
variables assigned in the controller are available in the templates.

An example `views/post/index.ecr`:
```
<% posts.each do |post| %>

<div class="blog-post">
  <h2 class="blog-post-title"><%= post.name %></h2>
  <p class="blog-post-body"><%= post.body %></p>

  <p>
    <a href="/posts/<%= post.id %>">read</a>
    | <a href="/posts/<%= post.id %>/edit">edit</a> | 
    <a href="/posts/<%= post.id %>?_method=delete" onclick="return confirm('Are you sure?');">delete</a>
  </p>
            
</div><!-- /.blog-post -->

<% end %>
```

### Models

The models are a simple ORM mechanism that will map objects to tuples.  The
mapping is done using a `sql_mapping` macro.

An example models/post.cr`
```
require "kemalyst"
require "kemalyst/adapter/pg"

class Post < Kemalyst::Model
  adapter pg
  
  sql_mapping({ 
    name: "VARCHAR(255)", 
    body: "TEXT" 
  })

end

```
The mapping will automatically create the id, created_at and updated_at column
mapping that follows the active_record convention in Rails.

There are several methods that are provided in the model.
- self.drop - "Drop table..."
- self.create - "Create table..."
- self.clear - "DELETE from table;"
- save - "Insert or Update depending on if ID is set" 
- destroy - "Delete from table where id = this.id;"
- all(where) "Select * from table;"
- find(id) - Select * from table where id = this.id limit 1;"

## Contributing

1. Fork it ( https://github.com/[your-github-name]/kemalyst/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[drujensen]](https://github.com/drujensen) drujensen - creator, maintainer
