require 'data_mapper'
require_relative './lib/file_loader.rb'
DataMapper.setup(:default, 'postgres://localhost/straymonds_data')

require_relative './models/record.rb'
require_relative './models/link.rb'

DataMapper.finalize
DataMapper.auto_migrate!
