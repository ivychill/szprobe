#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'json'

def destroy_all_roadtraffic
  puts "it may destory all road_traffic! be cautious! Yes to destroy/No to skip destroy but continue importing./Control-C to stop."
  a = gets.chomp
  return unless (a == "y")
  RoadTraffic.all.each do |road_traffic|
    road_traffic.destroy
  end
end

def convert_roadtraffic_to_v3(filePath, fileNo)
  beginTime = Time.now
  for idx in 1..(fileNo-1)
    file_json = filePath+'/roadtraffic-v2-frozen-20120822-'+idx.to_s+'.json'
    puts "converting "+file_json
    file = File.read(file_json)
    road_traffics = JSON.parse(file)
    total_records = road_traffics.size
    progress_idx = 0
    road_traffics.each do |road_traffic_v1|
      progress_idx = progress_idx + 1
      timeSpent = Time.now - beginTime
      puts Time.now.to_s+" processing "+progress_idx.to_s+"/"+total_records.to_s+". Spent: "+timeSpent.to_s+"s." if progress_idx%100 == 0
      road_traffic_v2 = RoadTraffic.find_or_create_by :ts => road_traffic_v1["snap_ts"], :rid => road_traffic_v1["road_id"], :rn => road_traffic_v1["rn"]
      road_traffic_v2.ts_in_sec = road_traffic_v2.ts.to_i
      segment = genSegment_v3 road_traffic_v2, road_traffic_v1["desc"]
      segment.spd = format_speed road_traffic_v1["spd"]
      segment.dir = direction_lexical road_traffic_v1["desc"]
      segment.duration = duration_lexical road_traffic_v1["desc"]
      segment.desc.gsub! /DDDDD/, segment.dir if segment.dir
      segment.desc.gsub! /TTTTT/, segment.duration if segment.duration
      segment.desc.gsub! /SSSSS/, segment.spd if segment.spd
      
      road_traffic_v2.save
    end
  end
end

#2012.08.22
destroy_all_roadtraffic
#convert_roadtraffic_to_v3 "/home/data/backup/szprobe-2.x", 12
convert_roadtraffic_to_v3('../data-for-test', 11)



