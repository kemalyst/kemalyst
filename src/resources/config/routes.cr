require "../src/controllers/*"

# uncomment the next line to enable Basic Authentication for the whole
# application.  You can specify a specific path and method types if you want
# to limit the Basic Authentication to specific routes.  You can also add the
# BasicAuth to a specific route using an array of handlers.
# all    "/*",                Kemalyst::Handler::BasicAuth.instance("admin", "password")

get    "/",                 DemoController::Index.instance

get    "/demos",            DemoController::Index.instance 
get    "/demos/new",        DemoController::New.instance
post   "/demos",            DemoController::Create.instance  

get    "/demos/:id",        DemoController::Show.instance
get    "/demos/:id/edit",   DemoController::Edit.instance  
put    "/demos/:id",        DemoController::Update.instance
delete "/demos/:id",        DemoController::Delete.instance
