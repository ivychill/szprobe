#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'json'

json = File.read('/tmp/poi.json')
roads = JSON.parse(json)

StaticRoad.all.each do |rs|
	rs.destroy
end

snap_json = File.read('/tmp/snaps.json')
$snaps = JSON.parse(snap_json)

def get_href(name)
	$snaps.each do |snap|
	#puts snap["city"]
		next unless snap["summaries"]
		snap["summaries"].each do |road|
		puts road["href"]+road["name"]
			return road["href"] if road["name"] == name
		end
	end
	return nil
end

roads.each do |rd|
	static_road = StaticRoad.find_or_create_by(:name => rd["name"])
	static_road.href = get_href rd["name"]
	next unless rd["pois"]
	rd["pois"].each do |poi|
		static_road.static_pois.new :lat => poi["X"], :lng => poi["Y"], :ref => poi["ref"], :ref_type => poi["ref_type"]
	end
	static_road.save
end


