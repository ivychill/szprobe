class CongestedRoad
  include Mongoid::Document
  field :rn, type: String
  field :href, type: String
  field :wap_url, type: String
  
  embedded_in :snap
end
