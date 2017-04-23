require "smtp"
require "yaml"
require "kilt"
require "kilt/slang"

class Kemalyst::Mailer
  property message : SMTP::Message

  def initialize
    if settings
      @@client ||= SMTP::Client.new(env(settings["host"].to_s), env(settings["port"].to_s).to_i)
      @message = SMTP::Message.new
    else
      raise "smtp needs to be set in the config/mailer.yml"
    end
  end

  def settings
    yaml_file = File.read("config/mailer.yml")
    yaml = YAML.parse(yaml_file)
    @@settings ||= yaml["smtp"].as(YAML::Any)
  end

  def from(email : String = "", name : String = "")
    @message.from = SMTP::Address.new(email, name)
  end

  def to(email : String = "", name : String = "")
    @message.to << SMTP::Address.new(email, name)
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
    content =  Kilt.render("src/views/{{filename.id}}", {{*args}})
    @message.body = Kilt.render("src/views/layouts/{{layout.id}}", {{*args}})
  end

  # helper to render a template as the body of the email.
  # The view name is relative to `src/views` directory.
  macro render(filename, *args)
    @message.body = Kilt.render("src/views/{{filename.id}}", {{*args}})
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
