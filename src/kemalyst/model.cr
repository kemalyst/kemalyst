require "yaml"

abstract class Kemalyst::Model

  # specify the database adapter you will be using for this model. 
  # mysql, pg, sqlite, etc.
  macro adapter(name)
    unless @@database
      yaml_file = File.read("config/database.yml")
      yaml = YAML.parse(yaml_file)
      settings = yaml["{{name.id}}"]
      @@database = Kemalyst::Adapter::{{name.id.capitalize}}.new(settings)
    end
  end  

  # sql_mapping is the mapping between columns in your database and the fields
  # in this model.  proerties will be created for each field.  The type of the
  # field is specific to the database you are using.  You may specify other
  # criteria for each field like `NOT NULL` and Referential Integrity. This
  # allows you to take full advantage of the database of choice.
  # you may also specify a specific table_name and if you want the timestamps
  # or not.  This will help with backward compatibility of existing databases.
  macro sql_mapping(names, table_name = nil, timestamps = true)
    {% name_space = @type.name.downcase.id %}
    {% table_name = name_space + "s" unless table_name %}
    # Table Name
    @@table_name = "{{table_name}}"
    #Create the properties
    property :id
    {% for name, type in names %}
    property {{name}}
    {% end %}
    {% if timestamps %}
    property :created_at, :updated_at
    {% end %}
    
    # Create the from_sql method
    def self.from_sql(result)
      {{name_space}} = {{@type.name.id}}.new
      {{name_space}}.id = result[0] 
      {% i = 1 %}
      {% for name, type in names %}
        {{name_space}}.{{name.id}} = result[{{i}}]
        {% i += 1 %}
      {% end %}

      {% if timestamps %}
        {{name_space}}.created_at = result[{{i}}]
        {{name_space}}.updated_at = result[{{i + 1}}]
      {% end %}
      return {{name_space}}
    end

    # keep a hash of the fields to be used for mapping
    def self.fields(fields = {} of String => String)
        {% for name, type in names %}
        fields["{{name.id}}"] = "{{type.id}}"
        {% end %}
        {% if timestamps %}
        fields["created_at"] = "TIMESTAMP"
        fields["updated_at"] = "TIMESTAMP"
        {% end %}
        return fields
    end

    # keey a hash of the params that will be passed to the adapter.
    def params
      return {
          {% for name, type in names %}
            "{{name.id}}" => {{name.id}},
          {% end %}
          {% if timestamps %}
            "created_at" => created_at,
            "updated_at" => updated_at,
          {% end %}
      }
    end

  end #End of Fields Macro


  # Clear is used to remove all rows from the table and reset the counter for
  # the id.
  def self.clear
    if db = @@database
      db.clear(@@table_name)
    end
  end

  # Drop will drop the table completely.  This will lose data so be very
  # careful with this call.
  def self.drop
    if db = @@database
      db.drop(@@table_name)
    end
  end

  # Create will create the table for you based on the sql_mapping specified.
  def self.create
    if db = @@database
      db.create(@@table_name, fields)
    end
  end

  # The save method will check to see if the @id exists yet.  If it does it
  # will call the update method, otherwise it will call the create method.
  # This will update the timestamps apropriately.
  def save
    if db = @@database
      if value = @id
        updated_at = Time.now
        db.update(@@table_name, self.class.fields, value, params)
      else
        @created_at = Time.now
        @updated_at = Time.now
        @id = db.insert(@@table_name, self.class.fields, params)
      end
    end
    return true
  end

  # Destroy will remove this from the database.
  def destroy
    if db = @@database
      return db.delete(@@table_name, @id)
    end
  end
  
  # All will return all rows in the database. The clause allows you to specify
  # a WHERE, JOIN, GROUP BY, ORDER BY and any other SQL92 compatible query to
  # your table.  The results will be an array of instantiated instances of
  # your Model class.  This allows you to take full advantage of the database
  # that you are using so you are not restricted or dummied down to support a
  # DSL.  
  def self.all(clause = "", params = {} of String => String)
    return self.query(@@table_name, fields({"id" => "INT"}), clause, params)
  end
  
  # find returns the row with the id specified.
  def self.find(id)
    return self.query_one(@@table_name, fields({"id" => "INT"}), id)
  end
  
  # query performs the select statement and calls the from_sql with the
  # results.
  def self.query(table_name, fields, clause, params = {} of String => String)
    rows = [] of self
    if db = @@database
      results = db.select(table_name, fields, clause, params)
      if results.is_a?(Array)
        if results.size > 0
          results.each do |result|
            rows << self.from_sql(result)
          end
        end
      end
    end
    return rows
  end

  # query_one is a convenience method for only returning the first instance of a
  # query.
  def self.query_one(table_name, fields, id)
    row = nil
    if db = @@database
      results = db.select_one(table_name, fields, id)
      if results.is_a?(Array)
        if results.size > 0
          row = self.from_sql(results.first)
        end
      end
    end
    return row
  end


end



