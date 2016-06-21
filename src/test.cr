require "./adapter/pg"
require "./kemalyst"

class Todo < Kemalyst::Model
  adapter pg
  
  sql_mapping({ 
    name: ["VARCHAR(255)", String]
  })

  def initialize(@name)
  end

end

result = Todo.query("SELECT column_name, data_type, character_maximum_length" \
           " FROM information_schema.columns WHERE table_name = 'todos';")
if result
  puts result.find{|col| col[0] == "name"}
end
