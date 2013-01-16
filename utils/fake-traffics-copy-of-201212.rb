#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)

$mylogger = Logger.new File.expand_path("../../log/fake_traffics_generator.log", __FILE__)
$worker_name = File.basename __FILE__, ".rb"
#$worker_name.match /(.*)(\d*)$/
#$worker_id = $2

context = ZMQ::Context.new(1)
$outbound2local = context.socket(ZMQ::PUB)
$outbound2local.connect("tcp://localhost:6003")

#将12月份的路况复制
#
day_of_today = Date.today.day
day_of_2012_dec = Date.new 2012, 12, day_of_today
$mylogger.info "A fresh new day! "+Time.now.to_s
road_traffics = RoadTraffic.where(:ts.gte => day_of_2012_dec, :ts.lte => day_of_2012_dec+1.day)

#gen traffic every 1 minute
road_traffics.each do |rt|
  traffic_time = Time.new 2012,12,day_of_today,Time.now.hour,Time.now.min,0
  while rt.ts_in_sec.to_i >= traffic_time.to_i do
    sleep 60
    traffic_time = Time.new 2012,12,day_of_today,Time.now.hour,Time.now.min,0
  end
  if (rt.ts_in_sec.to_i < traffic_time.to_i)
    rt.ts_in_sec = Time.now.to_i
    rt.ts = Time.now
    fake_traffic = [rt]
    puts fake_traffic.to_json
    $outbound2local.send_string fake_traffic.to_json 
  end
end

$mylogger.info "Done today! "+road_traffics.size.to_s+","+Time.now.to_s

