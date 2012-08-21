#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'json'

def convert_snaps_to_v2
  for idx in 0..12
    file_json = '/home/data/backup/szprobe-20120820-v1/snaps-v1-frozen-20120820-'+idx.to_s+'.json'
    file = File.read(file_json)
    snaps = JSON.parse(file)
    snaps.each do |snap_v1|
      snap_v2 = Snap.find_or_create_by :ts => snap_v1["recorded"], :city => snap_v1["city"]
      if snap_v1["summaries"]
        snap_v1["summaries"].each do |summary|
          congested_road = snap_v2.congested_roads.new :href => summary["href"], :rn => summary["name"]
          if summary["scopes"]
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
        end
        snap_v2.save
      end
    end
  end
end

convert_snaps_to_v2



