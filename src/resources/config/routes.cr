require "../src/controllers/*"
include Kemalyst::Handler

# This is an example of how to configure the Basic Authentication handler for
# a path.  In this example, Basic Authentication is configured for the whole
# site.  You could also have added this to the application.cr instead.
all    "/*",                Kemalyst::Handler::BasicAuth.instance("admin", "password")

# This is how to setup the root path:
get    "/",                 DemoController::Index.instance

# This is an example of a resource using a traditional site:
get    "/demos",            DemoController::Index.instance 
get    "/demos/new",        DemoController::New.instance
post   "/demos",            DemoController::Create.instance  
get    "/demos/:id",        DemoController::Show.instance
get    "/demos/:id/edit",   DemoController::Edit.instance  
put    "/demos/:id",        DemoController::Update.instance
delete "/demos/:id",        DemoController::Delete.instance
