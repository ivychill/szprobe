#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'json'

def get_href(name)
	RoadTraffic.where(:rn => name).limit(1).first.road_id
end

def fix_href
	StaticRoad.where(:href => nil).all.each do |static_road|
		static_road.href = get_href static_road.name
		static_road.save
	end
end

def check_null_href
	StaticRoad.where(:href => nil).all.each do |static_road|
		puts static_road.name
	end
end

def restore_static_roads_from_file
	puts "Be cautious! will rebuild static roads. y/n?"
	a=gets.chomp
	exit unless a == 'y'
	
	#json = File.read('static_roads-v2-frozen-20120822.json')
	json = File.read('static_roads-v2-frozen-20120906.json')
	roads = JSON.parse(json)
	
	StaticRoad.all.each do |rs|
		rs.destroy
	end
	
	roads.each do |rd|
		static_road = StaticRoad.find_or_create_by(:name => rd["name"], :href => rd["href"], :static_pois => rd["static_pois"])
		static_road.save
	end
end

check_null_href
#fix_href
restore_static_roads_from_file


