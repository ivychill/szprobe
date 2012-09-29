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

#formated desc: “拥堵路段：从 南山大道路口 到 北环大道路口，方向：西向，预计通行时间：130秒，速度：20km/h
#formated desc: “前方拥堵：从 南山大道路口 到 北环大道路口，西向
def genSegment_v3(road_traffic, desc)
  objs_to_process = traffic_lexical_v2(road_traffic.rn, desc)
  #formated_desc = "拥堵路段：从"+objs_to_process[0][:poi][:ref]+"到"+objs_to_process[1][:poi][:ref]+"，方向：DDDDD"+"，预计通行时间：TTTTT秒"+"，速度：SSSSSkm/h"
  formated_desc = "前方拥堵：从"+objs_to_process[0][:poi][:ref]+"到"+objs_to_process[1][:poi][:ref]+"，DDDDD"
  #objs_to_process = [{:desc=>from_ref, :poi => startPoi}, {:desc => to_ref, :poi => endPoi}]
  start_lat_lng = get_lat_lng(road_traffic.rn, objs_to_process[0][:poi][:ref])
  end_lat_lng = get_lat_lng(road_traffic.rn, objs_to_process[1][:poi][:ref])
  segment = road_traffic.segments.new :desc => formated_desc,
  				:s_lat => start_lat_lng[:lat], :s_lng => start_lat_lng[:lng],
  				:e_lat => end_lat_lng[:lat], :e_lng => end_lat_lng[:lng]
end

#formated desc: “拥堵路段：从 南山大道路口 到 北环大道路口，方向：西向，预计通行时间：130秒，速度：20km/h
#formated desc: “前方拥堵：从 南山大道路口 到 北环大道路口，西向
#泰然九路目前拥堵路段北向：泰然九路泰然四路口->时代科技大厦 速度：10km/h通行时间：1分钟40秒北向：泰然九路泰然六路口->泰然九路泰然四路口 速度：9km/h通行时间：1分钟16秒
def genSegment_wap_v1(road_traffic, seg)
  formated_desc = "从"+seg[:start][:ref]+"到"+seg[:end][:ref]+seg[:direction]
  start_lat_lng = get_lat_lng(road_traffic.rn, seg[:start][:ref])
  end_lat_lng = get_lat_lng(road_traffic.rn, seg[:end][:ref])
  segment = road_traffic.segments.new :desc => formated_desc,
  				:s_lat => start_lat_lng[:lat], :s_lng => start_lat_lng[:lng],
  				:e_lat => end_lat_lng[:lat], :e_lng => end_lat_lng[:lng]
  segment.spd = seg[:speed]
  segment.dir = seg[:direction]
  segment.duration = seg[:duration]
  segment
end

#puts genRoadTraffic("教育中路", "北向: 兴华路教育中路口->教育中路吉祥路口").to_json
#puts genRoadTraffic("教育中路", "南向: 兴华路教育中路口->教育中路联想大厦").to_json

