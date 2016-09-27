require 'sequel'
require_relative './lib/file_loader.rb'
require_relative './lib/link_builder.rb'
Sequel.connect('postgres://localhost/straymonds_data')
Sequel::Model.strict_param_setting = false

require_relative './models/record.rb'
require_relative './models/link.rb'

#FileLoader.perform
LinkBuilder.perform
