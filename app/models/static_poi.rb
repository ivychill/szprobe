class StaticPoi
  include Mongoid::Document
  field :ref, type: String
  field :ref_type, type: String
  field :lat, type: String
  field :lng, type: String
  
  field :fixed_at, type: Time
  
  embedded_in :static_road
end
