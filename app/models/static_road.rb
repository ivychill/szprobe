class StaticRoad
  include Mongoid::Document
  field :href, type: String
  field :name, type: String

  embeds_many :static_pois
end
