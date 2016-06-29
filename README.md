### WIP (Work In Progress)

[![Build Status](https://travis-ci.org/drujensen/kemalyst.svg?branch=master)](https://travis-ci.org/drujensen/kemalyst)

[![docrystal.org](http://docrystal.org/badge.svg)](http://docrystal.org/github.com/drujensen/kemalyst)

# Kemalyst

Kemalyst is a yarlf (yet another r5555 like framework) that is based on on
super fast [kemal](https://github.com/sdogruyol/kemal). The framework
leverages the http handlers which are similar to Rack middleware. The
controllers are also HTTP::Handlers that render the response.

One of the main differences Kemalyst provides is the ability to chain
controllers in your routes.cr.  For example, you can chain a WebSocket handler
before your Index controller to allow for upgrading the connection for
a specific route.

The model is a simple ORM mapping and supports MySQL, PG and SQLite.

The views are handled using `ecr` format and several macros to simplify
development.

## Installation

1. Install Crystal

You can find instructions on how to install Crystal from [Crystal's
Website](http://crystal-lang.org).  I recommend using
[crenv](https://github.com/pine613/crenv) to manage your crystal versions.

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
  mysql:
    github: waterlink/crystal-mysql
    branch: master
  sqlite3:
    github: manastech/crystal-sqlite3
    branch: master
```
and run `shards update`.

### Post Install

To keep a similar structure to yarlf, several directories and files will be
installed.  This structure should look familiar to you if your coming from a
Rails background.

## Usage

### Run Locally
To run the demo app locally:

1. build the app `crystal build --release src/app.cr`
2. run with `./app`
3. visit `http://0.0.0.0:3000/`


### Run With docker
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

### Sample Applications

Several sample applications are provided:

[Blog Kemalyst](https://github.com/drujensen/blog-kemalyst)
[Chat Kemalyst](https://github.com/drujensen/chat-kemalyst)

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
 - Session.instance - Provides a Cookie Session that can be accessed from the `context.session`
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
    # Kemalyst::Handler::Static.instance, # Disable Static and Session handlers since this is a REST Service
    # Kemalyst::Handler::Session.instance,
    Kemalyst::Handler::Params.instance,
    Kemalyst::Handler::Cors.instance, # Enable CORS for cross site capabilities
    Kemalyst::Handler::Router.instance
  ]
end
```

### Router

The router will perform a lookup based on the method and path and return the
chain of handlers you specify in the routes.cr file.

An example of a route would be:
```
get "/",   DemoController::Index.instance
```

You may chain multiple handlers in a route using an array:
```
get "/", [ BasicAuth.instance("username", "password"),
           DemoController::Index.instance ]
```

This is how you would configure a WebSocket Controller:
```
get "/", [ ChatController::Chat.instance,
           ChatController::Index.instance ]
```

See below for more information on how to create a WebSocket Controller.

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
  render   "filename.ecr" # renders an .ecr template
  render   "filename.ecr", "layout.ecr" # renders an .ecr template with layout
  redirect "path" # redirect to path
  text     "body", 200 #render text/plain response with status code of 200
  json     "{}".to_json, 200 #render application/json with status code of 200
  html     "<html></html>", 200 #render text/html with status code of 200
```

### WebSocket Controllers

The WebSocket Controller will handle upgrading a HTTP Request to a WebSocket
Connection.

An example WebSocket Controller:
```

class Chat < Kemalyst::WebSocket
  @sockets = [] of HTTP::WebSocket
  @messages = [] of String
   
  def call(socket : HTTP::WebSocket)
    @sockets.push socket
    socket.on_message do |message|
      @messages.push message
      @sockets.each do |a_socket|
        a_socket.send @messages.to_json
      end
    end
  end
end
```
The `Chat` class will override the `call` method that is expecting an
`HTTP::WebSocket` to be passed which it would maintain and properly handle
messages to and from each socket.

This class will manage an array of `HTTP::Websocket`s and configures the
`on_message` callback that will manage the messages that will be then be
passed on to all of the other sockets. 

To see a full example application, checkout
[Chat Kemalyst](https://github.com/drujensen/chat-kemalyst)

### Views

Views are rendered using [Kilt](http://github.com/jeromegn/kilt).  Currently,
there are 4 different templating languages supported by Kilt: `ecr`, `mustache`,
`slang` and `temel`.  Kilt will select the templating engine based on the
extension of the file so `index.ecr` will render the file using the ECR
engine.


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
  <div>
    <h2><%= post.name %></h2>
    <p><%= post.body %></p>
    <p>
      <a href="/posts/<%= post.id %>">read</a>
      | <a href="/posts/<%= post.id %>/edit">edit</a> |
      <a href="/posts/<%= post.id %>?_method=delete" onclick="return confirm('Are you sure?');">delete</a>
    </p>
  </div>
<% end %>
```

And an example of `views/layouts/main.ecr`:
```
<!DOCTYPE html>
<html>
  <head>
    <title>Example Layout</title>
    <link rel="stylesheet" href="/stylesheets/main.css">
  </head>
  <body>
    <div class="container">
      <div class="row">
        <div class="col-sm-12">
          <%= content %>
        </div>
      </div>
    </div>
  </body>
</html>
```
The `<%= content %>` is where the template will be rendered in the layout.

### Models

The models are a simple ORM mechanism that will map objects to rows in the
database.  The mapping is done using a `sql_mapping` macro.

An example `models/post.cr`
```crystal
require "kemalyst-model/adapter/pg"

class Post < Kemalyst::Model
  adapter pg

  sql_mapping({
    name: ["VARCHAR(255)", String],
    body: ["TEXT", String]
  })

end

```
The mapping will automatically create the id, created_at and updated_at column
mapping that follows the active_record convention in Rails.

There are several methods that are provided in the model.
- self.drop - DROP table...
- self.create - CREATE table...
- self.clear - DELETE from table
- self.migrate = Add/Update columns to match model definition
- self.prune - Remove any undefined fields from the database
- save - Insert or Update depending on if ID is set
- destroy - DELETE FROM table WHERE id = this.id
- all(where) SELECT * FROM table #{WHERE clause};"
- find(id) - SELECT * FROM table WHERE id = this.id LIMIT 1;"

You can find more details at [Kemalyst Model](https://github.com/drujensen/kemalyst-model)

### Validation

Another Library included with Kemalyst is validation of your models.
You can find more details at [Kemalyst Validators](https://github.com/drujensen/kemalyst-validators)

## Contributing

1. Fork it ( https://github.com/drujensen/kemalyst/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [drujensen](https://github.com/drujensen) drujensen - creator, maintainer
