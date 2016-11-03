#The Context holds the request and the response objects.  The context is
#passed to each handler that will read from the request object and build a
#response object.  Params and Session hash can be accessed from the Context.
class HTTP::Server::Context
  alias ParamTypes = Nil | String | Int64 | Float64 | Bool | Hash(String, JSON::Type) | Array(JSON::Type)

  # clear the params.
  def clear_params
    @params = HTTP::Params.new({} of String => Array(String))
  end

  # params hold all the parameters that may be passed in a request.  The
  # parameters come from either the url or the body via json or form posts.
  def params
    @params ||= HTTP::Params.new({} of String => Array(String))
  end

  # clear the session.  You can call this to logout a user.
  def clear_session
    @session = {} of String => String
  end

  # Holds a hash of session variables.  This can be used to hold data between
  # sessions.  It's recommended to avoid holding any private data in the
  # session since this is held in a cookie.  Also avoid putting more than 4k
  # worth of data in the session to avoid slow pageload times.
  def session
    @session ||= {} of String => String
  end

end
