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
    raise "Not Available for Sqlite"
  end

  def prune(table_name, fields)
    raise "Not Available for Sqlite"
  end

  def add_field(table_name, name, type, previous = nil)
    raise "Not Available for Sqlite"
  end
  
  def rename_field(table_name, from, to, type)
    raise "Not Available for Sqlite"
  end

  def remove_field(table_name, name)
    raise "Not Available for Sqlite"
  end

  # DML
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
    results = self.query("SELECT LAST_INSERT_ROWID()") as Array
    id = results[0][0] as Int64
    return id
  end
  
  def query(statement : String, params = {} of String => String, fields = {} of Symbol => String)
    conn = @pool.connection
    if conn
      begin
        results = conn.execute(statement, scrub_params(params))
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


