# Context is the environment which holds request/response specific
# information such as params, content_type e.g
class HTTP::Server
  class Context
    alias ParamTypes = Nil | String | Int64 | Float64 | Bool
    
    def clear_params
      @params = {} of String => ParamTypes
    end

    def params
      @params ||= {} of String => ParamTypes
    end

    def redirect(url, status_code = 302)
      @response.headers.add "Location", url
      @response.status_code = status_code
    end

  end
end
