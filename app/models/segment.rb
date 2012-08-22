class Segment
  include Mongoid::Document
  field :dir, type: String
  field :spd, type: String
  field :duration, type: String
  field :desc, type: String
  field :s_lat, type: String
  field :s_lng, type: String
  field :e_lat, type: String
  field :e_lng, type: String
  
  embedded_in :road_traffic
end
