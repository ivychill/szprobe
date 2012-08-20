class CongestedRoad
  include Mongoid::Document
  field :rn, type: String
  field :href, type: String
  
  embedded_in :snap
end
