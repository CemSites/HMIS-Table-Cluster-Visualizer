require 'sequel'
DB = Sequel.connect('postgres://localhost/straymonds_data')

DB.run "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

DB.drop_table(:links)

DB.create_table(:links) do
  primary_key :id
  Integer :source_link_id
  Integer :target_link_id
  String :match

  index :source_link_id
  index :target_link_id
end

DB.drop_table(:records)

DB.create_table(:records) do
  primary_key :id
  String :filename
  String :data, text: true

  index :filename
  index :data
end
