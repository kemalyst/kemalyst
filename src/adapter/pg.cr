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

  # DDL
  def create(table_name, fields)
    statement = String.build do |stmt|
      stmt << "CREATE TABLE #{table_name} ("
      stmt << "id SERIAL PRIMARY KEY, "
      stmt << fields.map{|name, type| "#{name} #{type}"}.join(",")
      stmt << ")"
    end
    return self.query(statement)
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

  # DML
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


