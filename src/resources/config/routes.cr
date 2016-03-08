require "../app/controllers/*"

get    "/",                 DemoController::Index.instance

get    "/demos",            DemoController::Index.instance 
get    "/demos/:id",        DemoController::Show.instance
get    "/demos/new",        DemoController::New.instance
post   "/demos/create",     DemoController::Create.instance  
get    "/demos/:id/edit",   DemoController::Edit.instance  
put    "/demos/:id/update", DemoController::Update.instance
delete "/demos/:id/delete", DemoController::Delete.instance
