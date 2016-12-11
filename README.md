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

You can find instructions on how to install Crystal from [Crystal's
Website](http://crystal-lang.org).  I recommend using
[crenv](https://github.com/pine613/crenv) to manage your crystal versions.

2. Create a Crystal App

```
crystal init app [your_app]
cd [your_app]
```
3. Add kemalyst dependency to your shard.yml
```
dependencies:
  kemalyst:
    github: drujensen/kemalyst

  pg:
    github: will/crystal-pg

  mysql:
    github: crystal-lang/crystal-mysql

  sqlite3:
    github: crystal-lang/crystal-sqlite3
```
and run `crystal deps`.

### Post Install

To keep a similar structure to yarlf, several directories and files will be
installed.  This structure should look familiar to you if your coming from a
Rails background.
 - /client - npm, webpack, and jasmine to support es6 and sass.  `npm run build`,
   `npm run test`, and `npm run lint`.
 - /config - Application and HTTP::Handler config's goes here.  The database.yml and routes.cr are here.
 - /db - holds the `migrate.cr` script and any other db related artifacts.
 - /lib - shards are installed here.
 - /public - Default location for html/css/js files.  The static handler points to this directory.  The client artifacts and compiled and placed here.
 - /spec - all the crystal specs go here.
 - /src - all the source code goes here.

The post install will only run if it doesn't find a `src/app.cr` file.

You may want to remove the remnants of `crystal init`:
```
rm src/[your_app].cr
rm -r src/[your_app]
rm spec/[your_app]_spec.cr
rm spec/spec_helper.cr_old
```

## Usage

### Run Locally
To test the demo app locally:

1. create a postgres database called `[your_app]`
2. run `export DATABASE_URL=postgres://[username]:[password]@localhost:5432/[your_app]`
3. migrate the database: `crystal db/migrate.cr`
4. run the specs: `crystal spec`

To build the demo app locally:

1. build the app `crystal build --release src/app.cr`
2. run with `./app`
3. visit `http://0.0.0.0:3000/`

### Run Sentry
[Sentry](https://github.com/samueleaton/sentry) is included in the `/dev'
directory.  Sentry will watch your `/src` and `/config` directories and will
build and run the application.

You can launch it using: `crystal run dev/sentry.cr`

### Run with Docker Compose
To run the demo app, we are including a `Dockerfile` and `docker-compose.yml`. If
you have docker setup, you should be able to run:
```
docker-compose build
docker-compose up -d
docker-compose logs -f
```
This will download an ubuntu/cedar image compatible with heroku and has all the
dependencies including a postgres database.

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
  render   "filename.ecr"       # renders an .ecr template
  render   "filename.ecr", "layout.ecr" # renders an .ecr template with layout
  redirect "path"               #redirect to path
  text     "body", 200          #render text/plain with status code of 200
  json     "{}".to_json, 200    #render application/json with status code of 200
  html     "<html></html>", 200 #render text/html with status code of 200
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
database. There is no dependency on using this model.  I recommend looking at
[Active Record.cr](https://github.com/waterlink/active_record.cr) by waterlink
as an alternative to this simplistic approach.

The mapping is done using a `sql_mapping` macro.

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
