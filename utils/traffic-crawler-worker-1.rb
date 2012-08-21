#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'httparty'

$mylogger = Logger.new File.expand_path("../../log/traffic_crawler_worker.log", __FILE__)
$worker_name = File.basename __FILE__, ".rb"
$worker_name.match /(.*)(\d*)$/
$worker_id = $2

context = ZMQ::Context.new(1)
inbound = context.socket(ZMQ::ROUTER)
puts "ipc://traffic.ipc-"+$worker_name
#inbound.bind("ipc://traffic.ipc-"+$worker_name)
inbound.bind("tcp://localhost:910"+$worker_id)
$outbound2local = context.socket(ZMQ::PUB)
$outbound2local.connect("tcp://localhost:6003")
$outbound2rc = context.socket(ZMQ::PUB)
$outbound2rc.connect("tcp://roadclouding.com:6003")

def getAssignedTasks
	assignedTasks = CrawlerTask.where(:carrier => $worker_name)
end

class Rep
  include HTTParty
  format :html
  http_proxy '127.0.0.1', 8087
end

$url_fixedpart = "http://wap.szicity.com/cm/jiaotong/szwxcsTrafficTouch/wap/roadInfo.do?roadid="
$reg_direction = /(东向|西向|南向|北向|东南向|西南向|东北向|西北向)/
$reg_speed = /(\d*)km\/h/i

#$last_checked = Time.now
$interval_between_two_commit = 1*60

#an input example
#<tr>
#<td> 南向: 深南中路口-&gt;南园路口</td>
#					  </tr>
#<tr>
#<td>速度：12km/h</td>
#				       </tr>
#<tr>
#<td>通行时间：1分钟4秒</td>
#				       </tr>
#<tr>
#<td> </td>
#					       </tr>
#<tr>
#<td> 北向: 南园路口-&gt;深南中路口</td>
#					  </tr>
#<tr>
#<td>速度：15km/h</td>
#				       </tr>
#<tr>
#<td>通行时间：55秒</td>
#				       </tr>

def fetchTrafficAndSave(task)
	$mylogger.info task.to_json
	puts task.to_json
	road_traffics = []
	begin
		task.crawler_links.each do |road|
		    	#$mylogger.info $url_fixedpart+road.href
		    	#puts $url_fixedpart+road.href+road.rn
		    	respHtml = Rep.get($url_fixedpart+road.href)
			doc = Nokogiri::HTML(respHtml)
		    	#$mylogger.info doc
		    	#puts doc
			doc.css("div.auto300 table tbody").each do |link|
				  #puts link
				  wholeDetails = link.css("tr")
				  #puts wholeDetails
				  #puts "kkkk"
				  if (wholeDetails.size == 3 || wholeDetails.size == 4)
				  #puts "ffff"
					  #road.desc = link.content
					  specifiedDesc = wholeDetails[0].content;
					  speedDesc = wholeDetails[1].content;
					  durationDesc = wholeDetails[2].content;
					  direction = ""
					  if $reg_direction.match(specifiedDesc)
					  	direction = $&
					  end
					  speed = ""
					  if $reg_speed.match(speedDesc)
					  	speed = $1
					  end
					  road_traffic = genRoadTraffic road.rn, specifiedDesc
					  road_traffic.spd = speed
					  road_traffic.dir = direction
					  road_traffic.road_id = road.href
					  road_traffic.snap_ts = task.snap_ts
					  road_traffic.duration = duration_lexical durationDesc
					  road_traffic.save
					  road_traffics.push road_traffic
					  puts  "one traffic generated for "+road_traffic.to_json
					  $mylogger.info "one traffic generated for "+road_traffic.to_json
				   end
			end
		end
		$mylogger.info "done one snap! "+task.snap_ts.to_s
		puts road_traffics.to_json
		$outbound2local.send_string road_traffics.to_json if road_traffics.size>0
		$outbound2rc.send_string road_traffics.to_json if road_traffics.size>0
	rescue 
		$mylogger.error "some errors happened:" + $!.to_s
		return
	end
end

loop do
	$mylogger.debug "in loop "+$worker_name
	msg = ""
	task_list = getAssignedTasks
	result = inbound.recv_string msg #first recv get peer address
	result = inbound.recv_string msg #second one get the payload
	$mylogger.debug task_list.to_json if task_list
	task_list.each do |task|
		fetchTrafficAndSave(task)
		task.destroy
	end
end