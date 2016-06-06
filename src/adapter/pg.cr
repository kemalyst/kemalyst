require "./base"
require "pg"

# PostgreSQL implementation of the Adapter
class Kemalyst::Adapter::Pg < Kemalyst::Adapter::Base
  @pool : ConnectionPool(PG::Connection?)

  def initialize(settings)
    database = env(settings["database"].to_s)
    @pool = ConnectionPool.new(capacity: 20) do
      retry = 10
      while retry > 0
        begin
          conn = PG.connect(database)
          retry = 0
        rescue ex : PQ::ConnectionError
          sleep 1
          retry -= 1
        end
      end
      if ex && conn == nil
        raise ex 
      end
      conn
    end
  end

  # remove all rows from a table and reset the counter on the id.
  def clear(table_name)
    self.query("DELETE FROM #{table_name}")
  end

  # drop the table
  def drop(table_name)
    return self.query("DROP TABLE IF EXISTS #{table_name}")
  end

  def create(table_name, fields)
    statement = String.build do |stmt|
      stmt << "CREATE TABLE #{table_name} ("
      stmt << "id SERIAL PRIMARY KEY, "
      stmt << fields.map{|name, type| "#{name} #{type}"}.join(",")
      stmt << ")"
    end
    return self.query(statement)
  end
  # Migrate is an addative only approach.  It adds new columns but never
  # delete them to avoid data loss.  If the column type or size changes, a new
  # column will be created and the existing one will be renamed to
  # old_{tablename} then the data will be copied to the new column.  You may
  # need to perform insert queries if the migration cannot determine
  # how to convert the data for you.
  def migrate(table_name, fields)
    db_schema = self.query("SELECT column_name, data_type, character_maximum_length" \
                           " FROM information_schema.columns WHERE table_name = '#{table_name}';")
    if db_schema && !db_schema.empty?
      prev = "id"
      fields.each do |name, type|
        #check to see if the field is in the db_schema
        columns = db_schema.select{|col| col[0] == name}
        if columns && columns.size > 0
          column = columns.first
          #check to see if the data_type matches
          #TODO: Create mapping between SQL types and DB types
          unless true #type.downcase.includes?(column[1] as String)
            rename_field(table_name, name, "old_#{name}", type)
            add_field(table_name, name, type, prev)
            copy_field(table_name, name, "old_#{name}")
          end
          #TODO: check to see if size matches
          # Ignore is a size is not specified in SQL definition
          #TODO: check to see if default matches
          # Ignore if default is not specified in SQL definition
          #TODO: check to see if other flags match
          # Ignore if other flags are not specificed in SQL definition
        else
          add_field(table_name, name, type, prev)
        end
        prev = name
      end
    else
      create(table_name, fields)
    end
  end

  # Prune will remove fields that are not defined in the model.  This should
  # be used after you have successfully migrated the colunns and data. 
  # WARNING: Be aware that if you have fields in your database that are not
  # apart of the model, they will be dropped!
  def prune(table_name, fields)
    db_schema = self.query("SELECT column_name, data_type, character_maximum_length" \
                           " FROM information_schema.columns WHERE table_name = '#{table_name}';")
    if db_schema
      db_schema.each do |column|
        name = column[0] as String
        unless name == "id" || fields.has_key? name
          remove_field(table_name, name)
        end
      end
    end
  end

  # Add a field to the table. Postgres does not support `AFTER` so the
  # previous field will be ignored.
  def add_field(table_name, name, type, previous = nil)
    statement = String.build do |stmt|
      stmt << "ALTER TABLE #{table_name} ADD COLUMN"
      stmt << " #{name} #{type}"
    end
    return self.query(statement)
  end

  # change a field in the table.
  def rename_field(table_name, old_name, new_name, type)
    statement = String.build do |stmt|
      stmt << "ALTER TABLE #{table_name} RENAME"
      stmt << " #{old_name} TO #{new_name}"
    end
    return self.query(statement)
  end
  
  def remove_field(table_name, name)
    statement = String.build do |stmt|
      stmt << "ALTER TABLE #{table_name} DROP COLUMN"
      stmt << " #{name}"
    end
    return self.query(statement)
  end

  # Copy data from one column to another
  def copy_field(table_name, from, to)
    statement = String.build do |stmt|
      stmt << "UPDATE #{table_name}"
      stmt << " SET #{to} = #{from}"
    end
    return self.query(statement)
  end

  # select performs a query against a table.  The table_name and fields are
  # configured using the sql_mapping directive in your model.  The clause and
  # params is the query and params that is passed in via .all() method
  def select(table_name, fields, clause = "", params = {} of String => String)
    statement = String.build do |stmt|
      stmt << "SELECT "
      stmt << fields.map{|name, type| "#{name}"}.join(",")
      stmt << " FROM #{table_name} #{clause}"
    end
    return self.query(statement, params, fields)
  end
  
  # select_one is used by the find method.
  def select_one(table_name, fields, id)
    statement = String.build do |stmt|
      stmt << "SELECT "
      stmt << fields.map{|name, type| "#{name}"}.join(",")
      stmt << " FROM #{table_name}"
      stmt << " WHERE id=:id LIMIT 1"
    end
    return self.query(statement, {"id" => id})
  end

  def insert(table_name, fields, params)
    statement = String.build do |stmt|
      stmt << "INSERT INTO #{table_name} ("
      stmt << fields.map{|name, type| "#{name}"}.join(",")
      stmt << ") VALUES ("
      stmt << fields.map{|name, type| ":#{name}"}.join(",")
      stmt << ") RETURNING id"
    end
    results = self.query(statement, params, fields)
    if results
      return (results[0][0] as Int32).to_i64
    end
  end
  
  # This will update a row in the database.
  def update(table_name, fields, id, params)
    statement = String.build do |stmt|
      stmt << "UPDATE #{table_name} SET "
      stmt << fields.map{|name, type| "#{name}=:#{name}"}.join(",")
      stmt << " WHERE id=:id"
    end
    if id
      params["id"] = "#{id}"
    end
    return self.query(statement, params, fields)
  end
  
  # This will delete a row from the database.
  def delete(table_name, id)
    return self.query("DELETE FROM #{table_name} WHERE id=:id", {"id" => id})
  end

  def query(statement : String, params = {} of String => String, fields = {} of Symbol => String)
    if params
      statement, params = scrub_query_and_params(statement, params, fields)
    end
    conn = @pool.connection 
    if conn
      begin
        results = conn.exec(statement, params)
        return results.rows
      ensure
        @pool.release
      end
    end
    return [] of String
  end


  alias SUPPORTED_TYPES = (Nil | String | Int32 | Int16 | Int64 | Float32 | Float64 | Bool | Time | Char)
  private def scrub_query_and_params(query, params, fields)
    new_params = [] of SUPPORTED_TYPES
    params.each_with_index do |key, value, index|
      if value.is_a? SUPPORTED_TYPES
        query = query.gsub(":#{key}", "$#{index+1}#{lookup_type(fields,key)}")
        new_params << value
      end
    end
    return query, new_params
  end

  # I can't find a way to lookup a symbol using a string.  This method
  # unfortunately traverses the map to find it.
  private def lookup_type(fields, key_as_string)
    if key_as_string == "id"
      return "::int"
    else
      fields.each do |key, pg_type|
        if key.to_s == key_as_string
          return "::#{pg_type.downcase}"
        end
      end
    end
    return ""
  end

end


