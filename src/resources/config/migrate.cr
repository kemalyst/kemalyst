require "../app/models/*"

# Currently the migration only drops and recreates the tables.  This will lose
# any data in these tables.  A safer approach would perform DDL SQL calls
# using Demo.query("alter table demos set...;")

Demo.drop
Demo.create

