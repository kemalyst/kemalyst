require "crypto/md5"
include Kemalyst

module SessionController
  
  class New < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      render "session/new.ecr", "main.ecr"
    end
  end

  class Create < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      username = context.params["username"]
      password = context.params["password"]

      #puts "Encrypted Password: #{Crypto::MD5.hex_digest(password)}"
      if username == "admin" && Crypto::MD5.hex_digest(password as String) == "5f4dcc3b5aa765d61d8327deb882cf99"
        context.session["authorized"] = "true"
      end
      redirect "/"
    end
  end

  class Delete < Controller
    def call(context)
      authorized = context.session.has_key?("authorized")
      context.clear_session
      redirect "/"
    end
  end

end

