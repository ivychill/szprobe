class RoadTraffic
  include Mongoid::Document
  field :rid, type: String
  field :rn, type: String
  field :ts, type: Time
  field :ts_in_sec, type: String
  
  index({ts:1})
  
  embeds_many :segments
end
