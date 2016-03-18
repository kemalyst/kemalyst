require "../src/controllers/*"

all    "/*",                Kemalyst::Handler::BasicAuth.instance("admin", "password")

get    "/",                 DemoController::Index.instance

get    "/demos",            DemoController::Index.instance 
get    "/demos/new",        DemoController::New.instance
post   "/demos",            DemoController::Create.instance  

get    "/demos/:id",        DemoController::Show.instance
get    "/demos/:id/edit",   DemoController::Edit.instance  
put    "/demos/:id",        DemoController::Update.instance
delete "/demos/:id",        DemoController::Delete.instance
