require "secure_random"

class HTTP::Request
  property uuid

  def uuid
    @uuid ||= SecureRandom.uuid
  end
end
