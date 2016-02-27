module Kemalyst::Handler
  class Logger < Base
    property app, filename

    def initialize
      @filename = "logs/development.log"

      @log = File.new(@filename, "a")
      @log.flush_on_newline = true
    end

    def call(context)
      time = Time.now
      call_next(context)

      status_code = context.response.status_code
      method = context.request.method
      resource = context.request.resource
      elapsed = elapsed_text(Time.now - time)

      output_message = "#{time} | #{status_code} | #{method} #{resource} - #{elapsed}\n"
      @log.write output_message.to_slice
      context
    end

    private def elapsed_text(elapsed)
      minutes = elapsed.total_minutes
      return "#{minutes.round(2)}m" if minutes >= 1

      seconds = elapsed.total_seconds
      return "#{seconds.round(2)}s" if seconds >= 1

      millis = elapsed.total_milliseconds
      return "#{millis.round(2)}ms" if millis >= 1

      "#{(millis * 1000).round(2)}µs"
    end
  end
end
