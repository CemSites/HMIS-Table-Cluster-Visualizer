require 'sequel'
require 'yaml'

config = YAML::load_file(File.join(__dir__, '../config.yml'))['config']
DB = Sequel.connect(config['database_string'])
Sequel::Model.strict_param_setting = false

#models
require_relative './models/record.rb'
require_relative './models/link.rb'
#lib
require_relative './lib/file_loader.rb'


FileLoader.perform
