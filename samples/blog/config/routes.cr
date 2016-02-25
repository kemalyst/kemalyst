require "../app/controllers/*"

get  "/login", SessionController::New.instance
post "/session/create", SessionController::Create.instance
get  "/logout", SessionController::Delete.instance

get  "/", PostController::Index.instance

get  "/posts", PostController::Index.instance 
get  "/posts/:id", PostController::Show.instance
get  "/posts/new", PostController::New.instance
post "/posts/create", PostController::Create.instance  
get  "/posts/:id/edit", PostController::Edit.instance  
post "/posts/:id/update", PostController::Update.instance
get  "/posts/:id/delete", PostController::Delete.instance
