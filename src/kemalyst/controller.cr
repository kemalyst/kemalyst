require "http"
require "kilt"
require "kilt/slang"
require "./helpers"

class Kemalyst::Controller
  include Kemalyst::Helpers
  property context : HTTP::Server::Context

  def initialize(@context)
  end

  def request
    context.request
  end

  def response
    context.response
  end

  def params
    context.params
  end

  def session
    context.session
  end

  def flash
    context.flash
  end

  def run_before_filter(method)
  end

  def run_after_filter(method)
  end
end
