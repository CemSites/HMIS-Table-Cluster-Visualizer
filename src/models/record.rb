class Record
  include DataMapper::Resource

  property :id,       Serial
  property :filename, String, :index => true
  property :data,     Text,   :index => true
end
