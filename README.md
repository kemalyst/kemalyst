[![Build Status](https://travis-ci.org/drujensen/kemalyst.svg?branch=master)](https://travis-ci.org/drujensen/kemalyst)

[Documentation](http://drujensen.github.io/kemalyst/)

# Kemalyst

Kemalyst is a yarlf (yet another rails like framework) that is based on on
super fast [kemal](https://github.com/sdogruyol/kemal). The framework
leverages the http handlers which are similar to Rack middleware.

The router and controllers are an extension of the same middleware so you can
chain any compatible HTTP::Handler before or after the routing handler so you
can limit a particular handler to a sub-tree of your routes.

The model is a simple ORM mapping and supports MySQL, PG and SQLite.

The views are handled using [kilt](https://github.com/jeromegn/kilt) and several macros to simplify
development.

## Installation

1. Install Crystal

You can find instructions on how to install Crystal from [Crystal's Website](http://crystal-lang.org).

2. Install Kemalyst Generator

[Kemalyst Generator](https://github.com/TechMagister/kemalyst-generator) is a command line tool similar to `rails`.

```
brew tap drujensen/kgen
brew install kgen
```

3. Initialize a new Kemalyst App using `kgen`
```
kgen init app [your_app]
cd [your_app]
shards update
```
This will generate a traditional web application:
 - /config - Application and HTTP::Handler config's goes here.  The database.yml and routes.cr are here.
 - /lib - shards are installed here.
 - /public - Default location for html/css/js files.  The static handler points to this directory.
 - /spec - all the crystal specs go here.
 - /src - all the source code goes here.

## Usage

Generate scaffolding for a resource:
```
kgen generate scaffold Post name:string description:text
```

This will generate scaffolding for a Post:
 - src/controllers/post_controller.cr
 - src/models/post.cr
 - src/views/post/*
 - db/migrations/[datetimestamp]_create_post.sql
 - spec/controllers/post_controller_spec.cr
 - spec/models/post_spec.cr
 - appends route to config/routes.cr
 - appends navigation to src/layouts/_nav.slang

### Run Locally
To test the demo app locally:

1. Create a new Postgres database called `[your_app]`
2. Run `export DATABASE_URL=postgres://[username]:[password]@localhost:5432/[your_app]` which exposes the database url to `config/database.yml`.
3. Migrate the database: `kgen migrate up`. You should see output like `
Migrating db, current version: 0, target: [datetimestamp]
OK   [datetimestamp]_create_shop.sql`
4. Run the specs: `crystal spec`
5. Start your app: `kgen watch`
6. Then visit `http://0.0.0.0:3000/`

Note: The `kgen watch` command uses [Sentry](https://github.com/samueleaton/sentry) to watch for any changes in your source files, recompiling automatically.

If you don't want to use Sentry, you can compile and run manually:

1. Build the app `crystal build --release src/[your_app].cr`
2. Run with `./[your_app]`
3. Visit `http://0.0.0.0:3000/`


### Run with Docker

Another option is to run using Docker.  A `Dockerfile` and `docker-compose.yml` is provided. If
you have docker setup, you should be able to run:
```
docker-compose build
docker-compose up -d
docker-compose logs -f
```

Now you should be able to hit the site:
```
open "http://localhost"
```

Docker Compose is running [Sentry](https://github.com/samueleaton/sentry) so
any changes to your `/src` or `/config` will re-build and run your
application.

### Cookie Session
You will need to set a secret for the session.  Run the following
command:
```
crystal eval "require \"secure_random\"; puts SecureRandom.hex(64)"
```
copy the secret and set this in `config/session.cr`.

### Sample Applications

Several sample applications are provided:

 - [Blog Kemalyst](https://github.com/drujensen/blog-kemalyst)
 - [Chat Kemalyst](https://github.com/drujensen/chat-kemalyst)
 - [ToDo Backend Kemalyst](https://github.com/drujensen/todo-backend-kemalyst)

### Configure App

All config settings are in the `/config` folder.  Each handler has its own
settings.  You will find the `database.yml` and `routes.cr` here. Checkout
the samples that demonstrates a traditional blog site and a websocket chat
app.

### Middleware HTTP::Handlers

There are 7 handlers that are pre-configured for Kemalyst:
 - Logger - Logs all requests/responses to the logger configured.
 - Error - Handles any Exceptions and renders a response.
 - Static - Delivers any static assets from the `./public` folder.
 - Session - Provides a Cookie Session hash that can be accessed from the `context.session["key"]`
 - Flash - Provides flash message hash that can be accessed from the `context.flash["danger"]`
 - Params - Unifies the parameters into `context.params["key"]`
 - Router - Routes requests to other handlers based on the method and path.

Other handlers available for Kemalyst:
 - BasicAuth - Provides Basic Authentication.
 - CORS - Handles Cross Origin Resource Sharing.
 - CSRF - Helps prevent Cross Site Request Forgery.

You may want to add, replace or remove handlers based on your situation.  You can do that in the
Application configuration `config/application.cr`:

```
Kemalyst::Application.config do |config|
  # handlers will be chained in the order provided
  config.handlers = [
    Kemalyst::Handler::Logger.instance,
    Kemalyst::Handler::Error.instance,
    Kemalyst::Handler::Params.instance,
    Kemalyst::Handler::CORS.instance,
    Kemalyst::Handler::Router.instance
  ]
end
```

### Router

The router will perform a lookup based on the method and path and return the
chain of handlers you specify in the `/config/routes.cr` file.

An example of a route would be:
```
get "/",   DemoController::Index
```

You may chain multiple handlers in a route using an array:
```
get "/", [ BasicAuth.instance("username", "password"),
           DemoController::Index.instance ]
```
or add them individually in the correct order:
```
get "/", BasicAuth.instance("username", "password")
get "/", DemoController::Index.instance
```

This is how you would configure a WebSocket Controller:
```
get "/", ChatController::Chat
get "/", ChatController::Index
```

See below for more information on how to create a WebSocket Handler.

You can use any of the following methods: `get, post, put, patch, delete, all`

You can use a `*` to chain a handler for all children of this path:
```
all    "/posts/*",   BasicAuth.instance("admin", "password")

# all of these will be secured with the BasicAuth handler.
get    "/posts/:id", DemoController::Show
put    "/posts/:id", DemoController::Update
delete "/posts/:id", DemoController::Delete

```

You can enable CSRF protection for all `post` and `put` calls:
```
post "/*",   CSRF
put  "/*",   CSRF
```

Then in your forms, add the `csrf_tag` using the helper method:
```
<form action="/demos/<%= demo.id %>" method="post">
  <%= csrf_tag(context) %>
  ...
</form>
```

You can use `:variable` in the path and it will set a
context.params["variable"] to the value in the url.

### Controllers

The Controller inherits from HTTP::Handler which is the middleware similar to
Rack's middleware.  The handlers are chained together in a linked-list and
each will perform some action against the HTTP::Server::Context and then call
the next handler in the chain.  The router will continue this chain for a
specific route.  The final handler should return the generated response that will be
returned as the body and then the chain will unwind and perform post handling.

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
  render   "filename.ecr"               # renders an .ecr template
  render   "filename.ecr", "layout.ecr" # renders an .ecr template with layout
  redirect "path"                       # redirect to path
  text     "body", 200                  # render text/plain with status code of 200
  json     "{}".to_json, 200            # render application/json with status code of 200
  html     "<html></html>", 200         # render text/html with status code of 200
```

### WebSocket Controllers

The WebSocket Controller will handle upgrading a HTTP Request to a WebSocket
Connection.

An example WebSocket Controller:
```crystal
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

It's important to realize that if the request is not asking to be upgraded to
a websocket, it will call the next handler in the path.  If there is no
more handlers configured, a 404 will be returned.

Here is an example routing configuration:
```crystal
get "/", ChatController::Chat
get "/", ChatController::Index
```
The first one is a WebSocket Controller and the second is a standard
Controller.  If the request is not a WebSocket upgrade request, it will
pass-through and call the second one that will return the html page.


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
      <% context.flash.each do |key, value| %>
        <div class="alert alert-<%= key %>">
          <p><%= value %></p>
        </div>
      <% end %>
      </div>

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
database.

The mapping is done using a `sql_mapping` macro.

An example `models/post.cr`
```crystal
require "kemalyst-model/adapter/pg"

class Post < Kemalyst::Model
  adapter pg

  sql_mapping({
    name: String,
    body: String
  })

end
```
The mapping will automatically create the id, created_at and updated_at column
mapping that follows the active_record convention in Rails.

There are several methods that are provided in the model.
- self.clear - DELETE from table
- save - Insert or Update depending on if ID is set
- destroy - DELETE FROM table WHERE id = :id
- all(where) SELECT * FROM table #{WHERE clause};"
- find(id) - SELECT * FROM table WHERE id = :id LIMIT 1;"
- find_by(field, value) - SELECT * FROM table WHERE field = :value LIMIT 1;"

You can find more details at [Kemalyst Model](https://github.com/drujensen/kemalyst-model)

### Validation

Another Library included with Kemalyst is validation of your models.
You can find more details at [Kemalyst Validators](https://github.com/drujensen/kemalyst-validators)

### i18n Support

[TechMagister](https://github.com/TechMagister) has created a HTTP::Handler that will integrate his i18n library.
You can find more details at [Kemalyst i18n](https://github.com/TechMagister/kemalyst-i18n)

## Contributing

1. Fork it ( https://github.com/drujensen/kemalyst/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [drujensen](https://github.com/drujensen) drujensen - creator, maintainer
- [TechMagister](https://github.com/TechMagister) TechMagister - contributor
