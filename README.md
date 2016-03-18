# WIP (Work In Progress)

# Kemalyst

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
  pg:
    github: will/crystal-pg
    branch: master
```
and run `shards update`.

### Post Install

To keep a similar structure to yarlf, we have generated a demo application
that you can use as example code in the `/src` directory.  This is crystal's
recommended source directory. 

## Usage

To run the demo app, we are including a Dockerfile and docker-compose.yml. If
you have docker setup, you should be able to run:
```
docker-compose up
```
This will download an ubuntu image and install all the dependencies including
crystal and mount the demo application.  It will also include a postgres db
image.  You will need to find the ip address of the docker-machine to hit the
demo app.  You can find that with:
```
docker-machine ip default
```
Note: your machine name may not be `default` so you should provide yours.

Next, you will need to set a secret for the session.  run the following
command:
```
crystal eval "require \"secure_random\"; puts SecureRandom.hex(64)"
```
copy the secret and set this in `config/session.cr`.

Finally, you will need to run the migrations:
```
docker-compose run web crystal db/migrate.cr
```
This will run the migration script and generate the tables.

### Configure App

All config settings are in the `/config` folder.  Each handler has its own
settings.  You will find the `database.yml` and `routes.cr` here. Checkout
the samples that demonstrates a traditional blog site and a websocket chat
app.

### Controllers

The Controller inherits from HTTP::Handler which is the middleware similar to
Rack's middleware.  The handlers are chained together in a linked-list and
each will perform some action against the HTTP::Server::Context and then call
the next handler in the chain.  The router will continue this chain for a
specific route.  The final handler should return the String that will be
rendered as the body and then the chain will unwind and perform post handling.

There are 6 handlers that are pre-configured for Kemalyst:
 - Kemalyst::Handler::Logger.instance @logger
 - Kemalyst::Handler::Error.instance
 - Kemalyst::Handler::Static.instance
 - Kemalyst::Handler::Session.instance
 - Kemalyst::Handler::Params.instance
 - Kemalyst::Handler::Router.instance  

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

### Views

Views are rendered using ECR format.  This is similar to Rails ERB.

The render method is configured to look in the "src/views" path to keep the
controllers simple.  You may also render with a layout which will look for
this in the "src/views/layouts" directory.

```
render "demo/index.ecr", "main.ecr" 

```
This will render the index.ecr template inside the main.ecr layout.

### Models

The models are a simple ORM mechanism that will map objects to tuples.  The
mapping is done using a `sql_mapping` macro:
```
class Post < Kemalyst::Model
  adapter mysql
  
  sql_mapping({ 
    name: "VARCHAR(255)", 
    body: "TEXT" 
  })

end

```
The mapping will automatically create the id, created_at and updated_at column
mapping that follows the active_record convention in Rails.

There are several methods that are provided in the model.
- self.clear
- self.drop
- self.create
- save
- destroy
- all(where)
- find(id)


## Contributing

1. Fork it ( https://github.com/[your-github-name]/kemalyst/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[drujensen]](https://github.com/drujensen) drujensen - creator, maintainer
