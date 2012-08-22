#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'json'

def destroy_all_roadtraffic
  puts "it will destory all road_traffic! be cautious! y/n"
  a = gets.chomp
  return unless (a == "y")
  RoadTraffic.all.each do |road_traffic|
    road_traffic.destroy
  end
end

def convert_roadtraffic_to_v3
  for idx in 0..11
    file_json = '/home/data/backup/szprobe-2.x/roadtraffic-v2-frozen-20120822-'+idx.to_s+'.json'
    puts "converting "+file_json
    file = File.read(file_json)
    road_traffics = JSON.parse(file)
    road_traffics.each do |road_traffic_v1|
      road_traffic_v2 = RoadTraffic.find_or_create_by :ts => road_traffic_v1["snap_ts"], :rid => road_traffic_v1["road_id"], :rn => road_traffic_v1["rn"]
      road_traffic_v2.segments.new :dir => road_traffic_v1["dir"], :spd => road_traffic_v1["spd"], :duration => road_traffic_v1["duration"], 
		                 :desc => road_traffic_v1["desc"], 
		                 :s_lat => road_traffic_v1["s_poi_lat"], :s_lng => road_traffic_v1["s_poi_lng"], 
		                 :e_lat => road_traffic_v1["e_poi_lat"], :e_lng => road_traffic_v1["e_poi_lng"]
      
      road_traffic_v2.save
    end
  end
end

#2012.08.22
destroy_all_roadtraffic
convert_roadtraffic_to_v3



