class CrawlerLink
  include Mongoid::Document
  field :href, type: String
  field :rn, type: String
  field :wap_url, type: String
  
  embedded_in :crawler_task
end
