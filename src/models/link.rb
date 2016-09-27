class Link
  include DataMapper::Resource

  property :id,             Serial
  property :source_link_id, Integer, :index => true
  property :target_link_id, Integer, :index => true
  property :match,          String
end
