class RawPoint
  include Mongoid::Document
  field :course, type: Float
  field :altitude, type: Float
  field :gen_at, type: Time
  field :latitude, type: Float
  field :logitude, type: Float
  
  embedded_in :traffic_stream
end
