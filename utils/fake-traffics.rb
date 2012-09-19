#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'httparty'
require 'nokogiri'

$mylogger = Logger.new File.expand_path("../../log/traffic_crawler_worker.log", __FILE__)
$worker_name = File.basename __FILE__, ".rb"
#$worker_name.match /(.*)(\d*)$/
#$worker_id = $2

context = ZMQ::Context.new(1)
$outbound2local = context.socket(ZMQ::PUB)
$outbound2local.connect("tcp://localhost:6003")
$outbound2rc = context.socket(ZMQ::PUB)
$outbound2rc.connect("tcp://roadclouding.com:6003")

#<RoadTraffic _id: 5052875c1e391b333400dfca, _type: nil, rid: "R03012", rn: "南山大道", ts: 2012-09-14 01:24:42 UTC, ts_in_sec: "1347585882", crawler_id: "traffic-crawler-worker-1"> 
#<Segment _id: 5052875c1e391b333400dfcb, _type: nil, dir: "蛇口方向", spd: "15", duration: "224", desc: "前方拥堵：从桃园路到桂庙路，蛇口方向", s_lat: "22.538141", s_lng: "113.931375", e_lat: "22.529976", e_lng: "113.930125">] 

def genFakeTraffic_ns
	begin
		road_traffic = RoadTraffic.new :rid => "R03012", :rn => "南山大道", :ts => Time.now, :ts_in_sec => Time.now.to_i, :crawler_id =>  "traffic-crawler-worker-1"
		road_traffic.segments.new :dir => "蛇口方向", :spd => "15", :duration => "224", :desc => "（测试）前方拥堵：从桃园路到桂庙路，蛇口方向", :s_lat => "22.538141", :s_lng => "113.931375", :e_lat => "22.529976", :e_lng => "113.930125"
		puts road_traffic.to_json
		$outbound2local.send_string road_traffic.to_json 
		$outbound2rc.send_string road_traffic.to_json 

	rescue 
		$mylogger.error "some errors happened:" + $!.to_s
		return
	end
end

#<RoadTraffic _id: 50375b531e391b9e69000008, _type: nil, rid: "S130129", rn: "福龙路", ts: 2012-08-24 10:45:34 UTC, ts_in_sec: "1345805134", crawler_id: "">
#<Segment _id: 50375b531e391b9e6900000a, _type: nil, dir: "北向", spd: "14", duration: "55", desc: "拥堵路段：从北环香蜜立交桥北到福龙山隧道南口，方向：北向，预计通行时间：55秒，速度：14km/h", s_lat: "22.564057", s_lng: "114.026322", e_lat: nil, e_lng: nil>

def genFakeTraffic_fl
	begin
		road_traffic = RoadTraffic.new :rid => "S130129", :rn => "福龙路", :ts => Time.now, :ts_in_sec => Time.now.to_i, :crawler_id =>  "traffic-crawler-worker-1"
		road_traffic.segments.new :dir => "北向", :spd => "15", :duration => "224", :desc => "（测试）拥堵路段：从北环香蜜立交桥北到福龙山隧道南口，方向：北向，预计通行时间：55秒，速度：14km/h", :s_lat => "22.565483", :s_lng => "114.026068", :e_lat => "22.571991", :e_lng => "114.023589"
		puts road_traffic.to_json
		$outbound2local.send_string road_traffic.to_json 
		$outbound2rc.send_string road_traffic.to_json 

	rescue 
		$mylogger.error "some errors happened:" + $!.to_s
		return
	end
end

loop do
	genFakeTraffic_ns
	genFakeTraffic_fl
	sleep 60
end