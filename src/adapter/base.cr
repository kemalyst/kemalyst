require "pool/connection"

# The Base Adapter specifies the interface that will be used by the model
# objects to perform actions against a specific database.  Each adapter needs
# to implement these methods.
abstract class Kemalyst::Adapter::Base

  # method used to lookup the environment variable if exists
  def env(value)
    env_var = value.gsub("${","").gsub("}", "")
    if ENV.has_key? env_var
      return ENV[env_var]
    else
      return value
    end
  end

  # method to perform a reverse mapping of Database Type to Crystal Type.
  def type_mapping(db_type)
    case db_type.upcase
    when .includes?("CHAR"), .includes?("TEXT") 
      String
    when .includes?("BIG")
      Int64
    when .includes?("INT"), .includes?("SERIAL")
      Int32
    when .includes?("DEC"), .includes?("NUM"), .includes?("DOUBLE"), includes?("FIXED")
      Float64
    when .includes?("REAL"), .includes?("MONEY"), includes?("FLOAT")
      Float32
    when .includes?("BOOL")
      Bool
    when .includes?("DATE"), .includes?("TIME")
      Time
    else
      Slice(UInt8) 
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
  
  # create will create the table based on the fields specified in the
  # sql_mapping defined in the model.
  abstract def create(table_name, fields)

  # rename the table.
  # TODO: Implement
  #abstract def rename(from_table_name, to_table_name)

  # copy the data from one table to another
  # TODO: Implement
  #abstract def copy(from_table_name, to_table_name)

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

  # Add a field to the table. Your field will be added after the `previous` if
  # specified.
  abstract def add_field(table_name, name, type, previous = nil)
  
  # Rename a field in the table
  abstract def rename_field(table_name, old_name, new_name, type)

  # Remove a field in the table.
  abstract def remove_field(table_name, name)

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

  # This will insert a row in the database and return the id generated.
  abstract def insert(table_name, fields, params) : Int64

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

  # Query directly to the database.
  abstract def query(statement : String, params = {} of String => String, fields = {} of Symbol => String) 

end

