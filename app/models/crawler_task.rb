class CrawlerTask
  include Mongoid::Document
  field :snap_ts, type: Time
  field :carrier, type: String
  field :status, type: Integer
  
  embeds_many :crawler_links
end
