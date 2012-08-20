#encoding: utf-8
#if test, please unmark # before require
#ENV["RAILS_ENV"] ||= 'development'
#require File.expand_path("../../../config/environment", __FILE__)
#require './lexical.rb'

def genRoadTraffic(road_name, desc)
  objs_to_process = traffic_lexical(road_name, desc)
  #objs_to_process = [{:desc=>from_ref, :poi => startPoi}, {:desc => to_ref, :poi => endPoi}]
  start_lat_lng = get_lat_lng(road_name, objs_to_process[0][:poi][:ref])
  end_lat_lng = get_lat_lng(road_name, objs_to_process[1][:poi][:ref])
  road_traffic = RoadTraffic.new :desc => desc, :rn => road_name,
  				:s_poi_ref => objs_to_process[0][:poi][:ref], :s_poi_reftype => objs_to_process[0][:poi][:ref_type], 
  				:s_poi_lat => start_lat_lng[:lat], :s_poi_lng => start_lat_lng[:lng],
  				:e_poi_ref => objs_to_process[1][:poi][:ref], :e_poi_reftype => objs_to_process[1][:poi][:ref_type], 
  				:e_poi_lat => end_lat_lng[:lat], :e_poi_lng => end_lat_lng[:lng]
end

def get_lat_lng(road_name, poi_ref)
  lat_lng = { :lat => nil, :lng => nil}
  road = StaticRoad.where(:name => road_name).first
  return lat_lng if !road || !road.static_pois
  poi = road.static_pois.where(:ref => poi_ref).first
  return lat_lng if !poi
  lat_lng[:lat] = poi.lat
  lat_lng[:lng] = poi.lng
  return lat_lng
end

#puts genRoadTraffic("教育中路", "北向: 兴华路教育中路口->教育中路吉祥路口").to_json
#puts genRoadTraffic("教育中路", "南向: 兴华路教育中路口->教育中路联想大厦").to_json

