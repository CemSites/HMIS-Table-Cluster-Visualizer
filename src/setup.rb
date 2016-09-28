require 'sequel'
require 'yaml'

config = YAML::load_file(File.join(__dir__, '../config.yml'))['config']
DB = Sequel.connect(config['database_string'])
Sequel::Model.strict_param_setting = false

DB.run "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

DB.drop_table?(:links)
DB.create_table(:links) do
  primary_key :id
  Integer :source_link_id
  Integer :target_link_id
  String :match

  index :source_link_id
  index :target_link_id
end

DB.drop_table?(:records)
DB.create_table(:records) do
  primary_key :id
  String :filename
  String :data, text: true

  index :filename
end
DB.run "CREATE INDEX data_trgm_idx ON records USING gist (data gist_trgm_ops);"

DB.drop_table?(:queries)
DB.create_table(:queries) do
  primary_key :id
  String :query_name
  String :result_ids, text: true
end
