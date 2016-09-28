require 'sequel'
require 'yaml'
require_relative './lib/file_loader.rb'

config = YAML::load_file(File.join(__dir__, '../config.yml'))['config']
DB = Sequel.connect(config['database_string'])
Sequel::Model.strict_param_setting = false

require_relative './models/record.rb'
require_relative './models/link.rb'

FileLoader.perform
