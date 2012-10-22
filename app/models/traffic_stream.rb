class TrafficStream
  include Mongoid::Document
  field :source, type: String
  field :received_at, type: Time

  embeds_many :raw_points

end
