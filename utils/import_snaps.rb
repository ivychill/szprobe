#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'json'

json = File.read('/home/data/backup/snaps-v1-20120820.json')
snaps = JSON.parse(json)

snaps.each do |snap_v1|
	snap_v2 = Snap.find_or_create_by :ts => snap_v1["recorded"], :city => snap_v1["city"]
	snap_v1.summaries.each do |summary|
		congested_road = snap_v2.congested_roads.new :href => summary["href"], :rn => summary["name"]
		summary["scopes"].each do |scope|
			objs_to_process = traffic_lexical(summary["name"], scope["details"])
			road_traffic = RoadTraffic.new :road_id => summary["href"], :rn => summary["name"], :snap_ts => snap_v1["recorded"],
		                 :dir => scope["direction"], :spd => scope["speed"], :duration => scope["duration"], 
		                 :desc => scope["details"], 
		                 :s_poi_ref => objs_to_process[0][:poi][:ref], :s_poi_reftype => objs_to_process[0][:poi][:ref_type], 
		                 :e_poi_ref => objs_to_process[1][:poi][:ref], :e_poi_reftype => objs_to_process[1][:poi][:ref_type]
		       	road_traffic.save
		end
	end
	
	snap_v2.save
end


