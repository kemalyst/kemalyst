require "./base"
require "sqlite3"

# Sqlite implementation of the Adapter
class Kemalyst::Adapter::Sqlite < Kemalyst::Adapter::Base
  @pool : ConnectionPool(SQLite3::Database)
  
  def initialize(settings)
    filename = env(settings["database"].to_s)
    @pool = ConnectionPool.new(capacity: 20) do
       SQLite3::Database.new(filename)
    end
  end

  # DDL
  def clear(table_name)
    self.query("DELETE FROM #{table_name}")
  end

  def drop(table_name)
    return self.query("DROP TABLE IF EXISTS #{table_name}")
  end

  def create(table_name, fields)
    statement = String.build do |stmt|
      stmt << "CREATE TABLE #{table_name} ("
      stmt << "id INTEGER NOT NULL PRIMARY KEY, "
      stmt << fields.map{|name, type| "#{name} #{type}"}.join(",")
      stmt << ")"
    end
    return self.query(statement)
  end

  def migrate(table_name, fields)

  end

  def select(table_name, fields, clause = "", params = {} of String => String)
    statement = String.build do |stmt|
      stmt << "SELECT "
      stmt << fields.map{|name, type| "#{name}"}.join(",")
      stmt << " FROM #{table_name} #{clause}"
    end
    return self.query(statement, params)
  end
  
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
      stmt << ")"
    end
    id = nil
    self.query(statement, params)
    results = self.query("SELECT LAST_INSERT_ROWID()", {} of String => String) as Array
    id = results[0][0] as Int64
    return id

  end
  
  def update(table_name, fields, id, params)
    statement = String.build do |stmt|
      stmt << "UPDATE #{table_name} SET "
      stmt << fields.map{|name, type| "#{name}=:#{name}"}.join(",")
      stmt << " WHERE id=:id"
    end
    if id
      params["id"] = "#{id}"
    end
    return self.query(statement, params)
  end
  
  def delete(table_name, id)
    return self.query("DELETE FROM #{table_name} WHERE id=:id", {"id" => id})
  end

  def query(query, params = {} of String => String)
    conn = @pool.connection
    if conn
      begin
        results = conn.execute(query, scrub_params(params))
      ensure
        @pool.release
      end
    end
    return results
  end

  alias SUPPORTED_TYPES = (Float64 | Int64 | Slice(UInt8) | String | Nil)

  private def scrub_params(params)
    new_params = {} of String => SUPPORTED_TYPES
    params.each do |key, value|
      if value.is_a? SUPPORTED_TYPES
        if value.is_a? Time
          new_params[key] = db_time(value)
        else
          new_params[key] = value
        end
      end
    end
    return new_params
  end

  private def db_time (time)
    formatter = Time::Format.new("%F %X")
    return formatter.format(time)
  end

end


