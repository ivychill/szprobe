class Snap
  include Mongoid::Document
  field :ts, type: Time
  field :city, type: String
  
  embeds_many :congested_roads
end
