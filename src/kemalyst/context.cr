# Extending the HTTP::Server::Context to support params and session 

class HTTP::Server::Context
  alias ParamTypes = Nil | String | Int64 | Float64 | Bool | Hash(String, JSON::Type) | Array(JSON::Type)

  def clear_params
    @params = {} of String => ParamTypes
  end

  def params
    @params ||= {} of String => ParamTypes
  end

  def clear_session
    @session = {} of String => String
  end

  def session
    @session ||= {} of String => String
  end

end
