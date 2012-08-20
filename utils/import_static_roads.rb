#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'json'

json = File.read('db/static_roads.json')
roads = JSON.parse(json)

StaticRoad.all.each do |rs|
	rs.destroy
end

roads.each do |rd|
	static_road = StaticRoad.find_or_create_by(:name => rd["name"], :href => rd["href"], :static_pois :=> rd["static_pois"])
	static_road.save
end


