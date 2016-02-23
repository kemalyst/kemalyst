module Kemalyst::Handler
  class Session < Base
    property secret_key

    def initialize
      @secret_key = "secret"
    end
    
  end
end


