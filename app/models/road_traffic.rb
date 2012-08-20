class RoadTraffic
  include Mongoid::Document
  field :road_id, type: String
  field :rn, type: String
  field :snap_ts, type: Time
  field :dir, type: String
  field :spd, type: String
  field :duration, type: String
  field :desc, type: String
  field :s_poi_ref, type: String
  field :s_poi_reftype, type: String
  field :s_poi_lat, type: String
  field :s_poi_lng, type: String
  field :e_poi_ref, type: String
  field :e_poi_reftype, type: String
  field :e_poi_lat, type: String
  field :e_poi_lng, type: String
end
