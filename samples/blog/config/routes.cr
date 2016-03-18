require "../src/controllers/*"

get    "/login", SessionController::New.instance
post   "/session/create", SessionController::Create.instance
get    "/logout", SessionController::Delete.instance

get    "/", PostController::Index.instance

get    "/posts", PostController::Index.instance 
get    "/posts/new", PostController::New.instance
post   "/posts", PostController::Create.instance  

get    "/posts/:id", PostController::Show.instance
get    "/posts/:id/edit", PostController::Edit.instance  
put    "/posts/:id", PostController::Update.instance
delete "/posts/:id", PostController::Delete.instance
