[![Build Status](https://travis-ci.org/drujensen/kemalyst.svg?branch=master)](https://travis-ci.org/drujensen/kemalyst)

[Documentation](http://drujensen.github.io/kemalyst/)

### Moved to Amber

We have joined forces with [Amber](http://www.ambercr.io) and have migrated most of the code and functionality over there.  We recommend looking at the project before starting anything new.  We will continue to maintain Kemalyst for bug fixes and crystal updates.

# Kemalyst

Kemalyst is a yarlf (yet another rails like framework) that is based on
super fast [kemal](https://github.com/sdogruyol/kemal). The framework
leverages http handlers which are similar to Rack middleware.

Kemalyst follows the MVC pattern:
  - Models are a simple ORM mapping and supports MySQL, PG and SQLite.
  - Views are handled using [kilt](https://github.com/jeromegn/kilt) which support ECR (Erb like), SLang (Slim like), Crustache (Mustache like) or Temel (not sure what it's like).
  - Controllers are http handlers that continue the chain of handlers after the routing takes place.

Kemalyst also supports:
  - WebSockets provide two way communication for webapps that need dynamic updates
  - Mailers render and deliver email via [smtp.cr](https://github.com/raydf/smtp.cr)
  - Jobs perform background tasks using [sidekiq.cr](https://github.com/mperham/sidekiq.cr)
  - Migrations provide ability to maintain your database schema's using [Micrate](https://github.com/juanedi/micrate)

Kemalyst also comes with a command line tool similar to `rails` called `kgen` to help you get started quickly.

## Installation

### Brew
1. Install Crystal

```sh
brew update
brew install crystal-lang
```

2. Install Kemalyst Generator

```sh
brew tap kemalyst/kgen
brew install kgen
```

### Linux / Ubuntu

1. Install Crystal

```sh
curl https://dist.crystal-lang.org/apt/setup.sh | sudo bash
sudo apt-get update
sudo apt-get install build-essential crystal
```
2. Find the latest version of kgen at https://github.com/kemalyst/kemalyst-generator/releases

2. Run the following. Make sure to update the version number to the latest:
```
export KGEN_VERSION=0.8.0 //or latest version
curl -L https://github.com/kemalyst/kemalyst-generator/archive/v$KGEN_VERSION.tar.gz | sudo tar xvz -C /usr/local/share/. && cd /usr/local/share/kemalyst-generator-$KGEN_VERSION && sudo crystal deps && sudo make
sudo ln -sf /usr/local/share/kemalyst-generator-$KGEN_VERSION/bin/kgen /usr/local/bin/kgen
```

3. Verify:
```
kgen --version
```

## Initialize

Create a new Kemalyst App using `kgen`
```sh
kgen init app [your_app] [options]
cd [your_app]
```

There are several options:
  - -d [pg | mysql | sqlite] - defaults to pg
  - -t [slang | ecr] - defaults to slang
  - --deps - install dependencies quickly.  This is the same as running `shards install`

This will generate a traditional web application:
 - /config - The `database.yml` and `routes.cr` are here.
 - /lib - shards (similar to gems in rails) are installed here.
 - /public - Default location for html/css/js files.
 - /spec - all the crystal specs go here.
 - /src - all the source code goes here.

## Generators

`kgen generate` provides several generators:
  - scaffold [name] [fields]
  - model [name] [fields]
  - controller [name] [methods]
  - mailer [name] [fields]
  - job [name] [fields]
  - migration [name]

An example to generate scaffolding for a resource:
```sh
kgen generate scaffold Post name:string body:text draft:bool
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
To test the app locally:

1. Create a new database called `[your_app]` in the db you chose.
2. Run `export DATABASE_URL=postgres://[username]:[password]@localhost:5432/[your_app]`or update the database url in `config/database.yml`.
3. Migrate the database: `kgen migrate up`. You should see output like `
Migrating db, current version: 0, target: [datetimestamp]
OK   [datetimestamp]_create_shop.sql`
4. Run the specs: `crystal spec`
5. Start your app: `kgen watch`
6. Then visit `http://0.0.0.0:3000`

Note: The `kgen watch` command uses [Sentry](https://github.com/samueleaton/sentry) to watch for any changes in your source files, recompiling automatically.

If you don't want to use Sentry, you can compile and run manually:

1. Build the app `crystal build --release src/[your_app].cr`
2. Run with `./[your_app]`
3. Visit `http://0.0.0.0:3000`


### Run with Docker

Another option is to run using Docker.  A `Dockerfile` and `docker-compose.yml` is provided. If
you have docker setup, you can run:
```sh
docker-compose up
```
Now visit the site:
```sh
open "http://localhost:3000"
```

Docker Compose is running [Sentry](https://github.com/samueleaton/sentry) as well so
any changes to your `/src` or `/config` will re-build and run your
application.

### Configure App

All config settings are in the `/config` folder.  Each handler has its own
settings.  You will find the `database.yml` and `routes.cr` here.


### Router

The router will perform a lookup based on the method and path and return the
chain of handlers you specify in the `/config/routes.cr` file.

You can use any of these simplified macros: `get, post, patch, delete, all`

```crystal
get "/", HomeController, :index
```

Or you can specify the class directly:
```crystal
get "/",   HomeController::Index
```
You can use `:variable` in the path and it will set a
context.params["variable"] to the value in the url.

```crystal
get    "/posts/:id", DemoController, :show
```

You may chain multiple handlers in a route:
```crystal
get "/", BasicAuth.instance("username", "password")
get "/", HomeController, :index
```

#### Resource Routes

You can declare RESTful routes by using `resources` or `resource`:

For multiple resources:
```crystal
resources Demo
```

is the same as:
```crystal
get "/demos", DemoController, :index
get "/demos/new", DemoController, :new
post "/demos", DemoController, :create
get "/demos/:id", DemoController, :show
get "/demos/:id/edit", DemoController, :edit
patch "/demos/:id", DemoController, :patch
delete "/demos/:id", DemoController, :delete
```

For a single resource:
```crystal
resource Demo
```

is the same as:
```crystal
get "/demo/new", DemoController, :new
post "/demo", DemoController, :create
get "/demo", DemoController, :show
get "/demo/edit", DemoController, :edit
patch "/demo", DemoController, :update
delete "/demo", DemoController, :delete
```

### Controllers

The Controller inherits from HTTP::Handler which is the middleware similar to
Rack's middleware.  The handlers are chained together in a linked-list and
each will perform some action against the HTTP::Server::Context and then call
the next handler in the chain.  The router will continue this chain for a
specific route.  The final handler should return the generated response that will be
returned as the body and then the chain will unwind and perform post handling.

An example of a controller:
```crystal
require "../models/post"

class PostController < Kemalyst::Controller
  def index
    posts = Post.all("ORDER BY created_at DESC")
    html render("post/index.ecr", "main.ecr")
  end
end
```

There are several helper macros that will set the content type and responses status:
```crystal
  redirect "path"                       # redirect to path
  html     "<html></html>", 200         # content type `text/html` with status code of 200
  text     "text", 200                  # content type `text/plain` with status code of 200
  json     "{}".to_json, 200            # content type `application/json` with status code of 200
  xml      "{}".to_xml, 200            # content type `application/xml` with status code of 200
```

There are two render methods that will generate a string that can be passed to the above macros:
```crystal
  render   "filename.ecr"               # renders an .ecr template
  render   "filename.ecr", "layout.ecr" # renders an .ecr template with layout
```

You can use the rendering engine to generate `html`, `json`, `xml` or `text`:
```crystal
require "../models/post"

class HomeController < Kemalyst::Controller
  def index
    posts = Post.all("ORDER BY created_at DESC")
    json render("post/index.json.ecr")
  end
end
```

### Views

Views are rendered using [Kilt](http://github.com/jeromegn/kilt).  Currently,
there are 4 different templating languages supported by Kilt: `ecr`, `mustache`,
`slang` and `temel`.  Kilt will select the templating engine based on the
extension of the file so `index.ecr` will render the file using the ECR
engine.


The render method is configured to look in the "src/views" path to keep the
controllers simple.  You may also render with a layout which will look for
this in the "src/views/layouts" directory.

```crystal
html render "post/index.ecr", "main.ecr"
```
This will render the index.ecr template inside the main.ecr layout. All local
variables assigned in the controller are available in the templates.

An example `views/post/index.ecr`:
```erb
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
```html
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

CSRF middleware is built in.  In your forms, add the `csrf_tag` using the helper method:
```erb
<form action="/demos/<%= demo.id %>" method="post">
  <%= csrf_tag(context) %>
  ...
</form>
```

### Models

The models are a simple ORM mechanism that will map objects to rows in the database.  The mapping is done using several macros.

An example `models/post.cr`
```crystal
require "kemalyst-model/adapter/pg"

class Post < Kemalyst::Model
  adapter pg
  field name : String
  field body : Text
  field published : Bool
  timestamps
end
```
The mapping will automatically create the id of type Int64.  If you include `timestamps`, a created_at and updated_at field
mapping is created that will automatically get updated for you.

You can override the table name:
```crystal
require "kemalyst-model/adapter/pg"

class Comment < Kemalyst::Model
  adapter pg
  table_name post_comments
  field post_id : Int64
  field name String
  field body : Text
end
```

You can override the `id` field:
```crystal
require "kemalyst-model/adapter/pg"

class Comment < Kemalyst::Model
  adapter pg
  primary my_id : Int32
  ...
end
```

There are several methods that are provided in the model.
- self.clear - "DELETE from table;" that will help with specs
- save - Insert or update depending on if id is set
- destroy(id) - "DELETE FROM table WHERE id = #{id}"
- all(where) "SELECT * FROM table #{where};"
- find(id) - "SELECT * FROM table WHERE id = #{id} LIMIT 1;"
- find_by(field, value) - "SELECT * FROM table WHERE #{field} = #{value} LIMIT 1;"

You can find more details at [Kemalyst Model](https://github.com/drujensen/kemalyst-model)

### WebSocket Controllers

The WebSocket Controller will handle upgrading a HTTP Request to a WebSocket
Connection.

An example WebSocket Controller:
```crystal
class Chat < Kemalyst::WebSocket
  @sockets = [] of HTTP::WebSocket

  def call(socket : HTTP::WebSocket)
    @sockets.push socket
    socket.on_message do |message|
      @sockets.each do |a_socket|
        a_socket.send message.to_json
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

To see an example application, checkout
[Chat Kemalyst](https://github.com/drujensen/chat-kemalyst)

### Mailers

Kemalyst provides the ability to generate mailers:
```sh
kgen g mailer Welcome email:string name:string
```

This will generate the following files:

  - config/mailer.yml
  - spec/mailers/welcome_mailer_spec.cr
  - src/mailers/welcome_mailer.cr
  - src/views/layouts/mailer.slang
  - src/views/mailers/welcome_mailer.slang

The mailer has the ability to set the `from`, `to`, `cc`, `bcc`, `subject` and `body`.
You may use the `render` helper to create the body of the email.

```crystal
class WelcomeMailer < Kemalyst::Mailer
  def initialize
    super
    from "Kemalyst", "info@kemalyst.com"
  end

  def deliver(name: String, email: String)
    to name: name, email: email
    subject "Welcome to Kemalyst"
    body render("mailers/welcome_mailer.slang", "mailer.slang")
    super()
  end
end
```

To delivery a new email:
```crystal
mailer = WelcomeMailer.new
mailer.deliver(name, email)
```

You can deliver this in the controller but you may want to do this in a background job.

### Jobs

Kemalyst provides a generator for with integration user sidekiq.cr for background jobs:
```sh
kgen g job Welcome name:string email:string
```

This will generate:
  - config/sidekiq.cr
  - docker-sidekiq.yml
  - spec/jobs/spec_helper.cr
  - spec/jobs/welcome_job_spec.cr
  - src/jobs/welcome_job.cr
  - src/sidekiq.cr

Jobs are using `sidekiq.cr` for handling the background process.  Sidekiq uses `redis` to handle the queues and spins up several fibers to handle processing each job from the queue.

You will either need to install `redis` locally or you can use the `docker-sidekiq.yml` which is a pre-configured docker-compose file that will spin up the needed services.

To install redis locally and start the service:

```sh
brew install redis
brew services start redis
```

Sidekiq is expecting two environment variables to be configured:

```sh
export REDIS_PROVIDER = REDIS_URL
export REDIS_URL = redis://localhost:6379
```

Then you can start and watch the sidekiq service using `kgen`:
```sh
kgen sidekiq
```
This will watch for any changes to the jobs and recompile and launch sidekiq.

Or you can compile and run the sidekiq.cr manually:
```sh
crystal build --release src/sidekiq.cr
./sidekiq
```

Here is an example background job that will deliver the email we created earlier:
```crystal
require "sidekiq"
require "../mailers/welcome_mailer"

class WelcomeJob
  include Sidekiq::Worker

  def perform(name : String, email : String)
    mailer = WelcomeMailer.new
    mailer.deliver(name: name, email: email)
  end
end
```

To execute the job, in your controller call:
```crystal
WelcomeJob.async.perform(name, email)
```
#### docker-sidekiq.yml

If you have docker installed, you can spin up all of the services needed with:
```sh
docker-compose -f docker-sidekiq.yml up
```

This will spin up the following containers:
  - web: your web application using the command `kgen watch`
  - sidekiq: sidekiq service using the command `kgen sidekiq`
  - migrate: runs the migration scripts using the command `kgen migrate up`
  - sidekiqweb: web interface to manage the sidekiq queues at http://localhost:3001
  - mail: mail catcher smtp service on port 1025. You can view the email at http://localhost:1080
  - redis: runs a redis instance version 3.2 on port 6379
  - db: Mysql on port 3306 or Postgres on port 5432.  Sqlite doesn't need a db since it file based.

### Validation

Another Library included with Kemalyst is validation of your models.
You can find more details at [Kemalyst Validators](https://github.com/drujensen/kemalyst-validators)

### i18n Support

[TechMagister](https://github.com/TechMagister) has created a HTTP::Handler that will integrate his i18n library.
You can find more details at [Kemalyst i18n](https://github.com/TechMagister/kemalyst-i18n)

### Middleware HTTP::Handlers

There are 9 handlers that are pre-configured for Kemalyst.  This is similar in architecture to Rack Middleware:
 - Logger - Logs all requests/responses to the logger configured.
 - Error - Handles any Exceptions and renders a response.
 - Static - Delivers any static assets from the `./public` folder.
 - Session - Provides a Cookie Session hash that can be accessed from the `context.session["key"]`
 - Flash - Provides flash message hash that can be accessed from the `context.flash["danger"]`
 - Params - Unifies the parameters into `context.params["key"]`
 - Method - Provides ability to override the method using `_method` parameter
 - CSRF - Helps prevent Cross Site Request Forgery.
 - Router - Routes requests to other handlers based on the method and path.

Other handlers available for Kemalyst:
 - CORS - Handles Cross Origin Resource Sharing.
 - BasicAuth - Provides Basic Authentication.

You may want to add, replace or remove handlers based on your situation.  You can do that in the
Application configuration `config/application.cr`:

```crystal
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

## Acknowledgement

Kemalyst is only possible with the use and help from many other crystal projects and developers.  Special thanks to you and your contributions!

  - First and foremost the [Crystal Team](https://github.com/crystal-lang/crystal/graphs/contributors).
  - [Kemal](https://github.com/kemalcr/kemal) Originally forked from here - [Serdar Dogruyol](https://github.com/sdogruyol)
  - [spec-kemal](https://github.com/kemalcr/spec-kemal) - Kemal Spec for easy testing  [Serdar Dogruyol](https://github.com/sdogruyol)

  - [Kilt](https://github.com/jeromegn/kilt) Rendering templates - [Jerome Gravel-Niquet](https://github.com/jeromegn)
  - [Slang](https://github.com/jeromegn/slang) Slim-inspired templating language - [Jerome Gravel-Niquet](https://github.com/jeromegn)
  - [Radix](https://github.com/luislavena/radix) Router is mostly copied from here - [Luis Lavena](https://github.com/luislavena)
  - [smtp.cr](https://github.com/raydf/smtp.cr) SMTP Client for mailers - [Rayner De Los Santos F.](https://github.com/raydf)
  - [crystal-db](https://github.com/crystal-lang/crystal-db) Common database driver - [Brian J. Cardiff](https://github.com/bcardiff)
  - [crystal-sqlite](https://github.com/crystal-lang/crystal-sqlite) Sqlite Driver - [Brian J. Cardiff](https://github.com/bcardiff)
  - [crystal-mysql](https://github.com/crystal-lang/crystal-mysql) Mysql Driver - [Brian J. Cardiff](https://github.com/bcardiff)
  - [crystal-pg](https://github.com/will/crystal-pg) Postgres Driver - [Will Leinweber](https://github.com/will)
  - [sidekiq.cr](https://github.com/mperham/sidekiq.cr) Sidekiq - [Mike Perham](https://github.com/mperham)

For Kemalyst Generator
  - [mocks](https://github.com/waterlink/mocks.cr) Mocking Library - [Oleksii Fedorov](https://github.com/waterlink)
  - [Crystal CLI](mosop/cli) CLI Library - [mosop](https://github.com/mosop)
  - [Teeplate](mosop/teeplate) Template Rendering Library - [mosop](https://github.com/mosop)
  - [ICR](https://github.com/greyblake/crystal-icr) Interactive Crystal - [Sergey Potapov](https://github.com/greyblake)
  - [Sentry](https://github.com/samueleaton/sentry) Watch files, recompile and run - [Sam Eaton](https://github.com/samueleaton)
  - [Micrate](https://github.com/juanedi/micrate) Rails like Migration Tool - [Juan Edi](juanedi)

## Contributing

1. Fork it ( https://github.com/drujensen/kemalyst/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [drujensen](https://github.com/drujensen) Dru Jensen - creator, maintainer
- [TechMagister](https://github.com/TechMagister) Arnaud Fernandés - contributor
- [elorest](https://github.com/elorest) Isaac Sloan - contributor
