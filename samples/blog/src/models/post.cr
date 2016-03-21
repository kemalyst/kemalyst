require "kemalyst"
require "kemalyst/adapter/mysql"
require "markdown/markdown"

class Post < Kemalyst::Model
  adapter mysql
  
  sql_mapping({ 
    name: "VARCHAR(255)", 
    body: "VARCHAR(2000)" 
  })

  def last_updated
    last_updated = updated_at
    if last_updated.is_a?(String)
      last_updated = Time::Format.new("%F %X").parse(last_updated)
    end
    if last_updated.is_a?(Time)
      formatter = Time::Format.new("%B %d, %Y")
      last_updated = formatter.format(last_updated)
    end
    return last_updated
  end

  def markdown_body
    markdown_body = body
    if markdown_body.is_a?(String)
      markdown_body = Markdown.to_html(markdown_body)
    end
    return markdown_body
  end
end
