# WIP (Work In Progress)

# Kemalyst

Kemalyst is a yarlf (yet another rails like framework) that is based on on
super fast [kemal](https://github.com/sdogruyol/kemal). The framework
leverages the http handlers which are similar to Rack middleware. The
controllers are also HTTP::Handlers that render the response.  You can chain
handlers in your routes.cr.  For example, you can chain a WebSocket handler
before your Index handler to allow for upgrading the connection for a specific
route.  Another use case is adding a BasicAuth handler per route.

The model is a simple ORM mapping and supports MySQL, PG and SQLite. 

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

  # the demo app uses sqlite but you can change this to MySQL or PG or remove a
  # database dependency all together.

  sqlite3:
    github: manastech/crystal-sqlite3
    version: 0.1.0
```
and run `crystal deps`.

To keep a similar structure to yarlf, we have generated a demo application
that you can use as scaffolding for future development. 

## Usage

To run the sample scaffolding app, you will need to run the migrations and then start the
app.
```
crystal db/migate.cr
crystal app/demo.cr
```

1. Configure App

All config settings are in the `/config` folder.  Each handler has its own
settings.  You will find the `database.yml` file and routes.cr here. Checkout
the samples that demonstrates a traditional blog site and a websocket chat
app.

2. Create Controller

A controller inherits from HTTP:Handler which is the middleware similar to
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

The router will lookup based on the method and path and return the list of handlers you specify in
the routes.cr file.

An example of a route would be:
```
get "/", DemoController::Index.instance
```

You may also pass in a block similar to sinatra or kemal:

```
get "/" do |context|
  status "Great job!", 200
end
```

You may chain multiple handlers in a route using an array:
```
get "/", [ BasicAuth.instance("username", "password") , 
           DemoController::Index.instance ]
```

And this is how you would configure a WebSocket with BasicAuth:
```
get "/", [ WebSocket.instance(ChatController::Chat.instance),
           BasicAuth.instance("username", "password"),
           ChatController::Index.instance ]
```

3. Create View

Views currently only support ECR but we will add other templating languages
soon:

The render method is configured to look in the "app/views" path to keep the
controllers simple.  You may also render with a layout which will look for
this in the "app/views/layouts" directory.

```
render "demo/index.ecr", "main.ecr" 

```
This will render the index.ecr template inside the main.ecr layout.

4. Create Model

The models are a simple ORM mechanism that will map objects to tuples.  The
mapping is done using a sql_mapping macro:
```
class Post < Kemalyst::Model
  adapter mysql
  
  sql_mapping({ 
    name: "VARCHAR(255)", 
    body: "TEXT" 
  })

end

```
The mapping will create the id, created_at and updated_at column mapping that
follows the active_record convention in Rails.

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
