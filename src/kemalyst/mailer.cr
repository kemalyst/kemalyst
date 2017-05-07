require "smtp"
require "yaml"
require "kilt"
require "kilt/slang"

class Kemalyst::Mailer
  property message : SMTP::Message

  def initialize
    if url = ENV["SMTP_URL"]? || env(settings["url"].to_s)
      if url.includes? ":"
        host, port = url.split(":")
      else
        host, port = url, "25"
      end
      @@client ||= SMTP::Client.new(host, port.to_i)
      @message = SMTP::Message.new
    else
      raise "smtp url needs to be set in the config/mailer.yml or SMTP_URL environment variable"
    end
  end

  SMTP_YML = "config/mailer.yml"
  def settings
      if File.exists?(SMTP_YML) &&
        (yaml = YAML.parse(File.read SMTP_YML)) &&
        (settings = yaml["smtp"])
        settings
      else
        return {"url": "localhost:25"}
      end
  end

  def from(email : String = "", name : String = "")
    @message.from = SMTP::Address.new(email, name)
  end

  def to(email : String = "", name : String = "")
    @message.to << SMTP::Address.new(email, name)
  end

  def cc(email : String = "", name : String = "")
    @message.cc << SMTP::Address.new(email, name)
  end

  def bcc(email : String = "", name : String = "")
    @message.bcc << SMTP::Address.new(email, name)
  end

  def subject(@subject : String)
    @message.subject = @subject
  end

  def body(body : String)
    @message.body = body
  end

  # helper to render a view with a layout as the body of the email.
  # The view name is relative to `src/views` directory and the
  # layout is relative to `src/views/layouts` directory.
  macro render(filename, layout, *args)
    content = render("{{filename.id}}", {{*args}})
    render("layouts/{{layout.id}}")
  end

  # helper to render a template as the body of the email.
  # The view name is relative to `src/views` directory.
  macro render(filename, *args)
    Kilt.render("src/views/{{filename.id}}", {{*args}})
  end

  # deliver the email
  def deliver
    if client = @@client
      client.send @message
    end
  end

  # Helper method to get the logger
  def logger
    Kemalyst::Application.instance.logger
  end

  # method used to lookup the environment variable if exists
  private def env(value)
    env_var = value.gsub("${", "").gsub("}", "")
    if ENV.has_key? env_var
      return ENV[env_var]
    else
      return value
    end
  end
end
