require "./base"
require "mysql"

# Mysql implementation of the Adapter
class Kemalyst::Adapter::Mysql < Kemalyst::Adapter::Base
  @pool : ConnectionPool(MySQL::Connection)
  
  def initialize(settings)
    host = env(settings["host"].to_s)
    port = env(settings["port"].to_s)
    username = env(settings["username"].to_s)
    password = env(settings["password"].to_s)
    database = env(settings["database"].to_s)
    @pool = ConnectionPool.new(capacity: 20) do
       MySQL.connect(host, username, password, database, port.to_u16, nil)
    end
  end

  # DDL
  #Using TRUNCATE instead of DELETE so the id column resets to 0
  def clear(table_name)
    self.query("TRUNCATE #{table_name}")
  end
  
  def create(table_name, fields)
    statement = String.build do |stmt|
      stmt << "CREATE TABLE #{table_name} ("
      stmt << "id INT NOT NULL AUTO_INCREMENT, "
      stmt << fields.map{|name, type| "#{name} #{type}"}.join(",")
      stmt << ", PRIMARY KEY (id))"
      stmt << " ENGINE=InnoDB"
      stmt << " DEFAULT CHARACTER SET = utf8"
    end
    return self.query(statement)
  end

  # Add a field to the table. Your field will be added after the `previous` if
  # specified.
  def add_field(table_name, name, type, previous = nil)
    statement = String.build do |stmt|
      stmt << "ALTER TABLE #{table_name} ADD COLUMN"
      stmt << " #{name} #{type}"
      if previous
        stmt << " AFTER #{previous}"
      end
    end
    return self.query(statement)
  end
  
  # rename a field in the table.
  def rename_field(table_name, old_name, new_name, type)
    statement = String.build do |stmt|
      stmt << "ALTER TABLE #{table_name} CHANGE"
      stmt << " #{old_name} #{new_name} #{type}"
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
      stmt << ")"
    end
    self.query(statement, params)
    results = self.query("SELECT LAST_INSERT_ID()")
    if results
      return (results[0][0] as Int64)
    end
  end
  
  def query(statement : String, params = {} of String => String, fields = {} of Symbol => String)
    results = nil
    
    if conn = @pool.connection
      begin
        results = MySQL::Query.new(statement, scrub_params(params)).run(conn)
      ensure
        @pool.release
      end
    end
    return results
  end

  alias SUPPORTED_TYPES = (Nil | String | Float64 | Time | Int32 | Int64 | Bool | MySQL::Types::Date)

  private def scrub_params(params)
    new_params = {} of String => SUPPORTED_TYPES
    params.each do |key, value|
      if value.is_a? SUPPORTED_TYPES
        new_params[key] = value
      end
    end
    return new_params
  end

end

