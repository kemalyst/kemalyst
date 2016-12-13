require "../spec_helper"

class TestHandler < Kemalyst::Handler::Base
  def call(context)
    if self.next != nil
      call_next context
    else
      "All"
    end
  end
end
