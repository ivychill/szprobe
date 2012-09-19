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
$new_outbound2local = context.socket(ZMQ::PUB)
$new_outbound2local.connect("tcp://localhost:7003")
$new_outbound2rc = context.socket(ZMQ::PUB)
$new_outbound2rc.connect("tcp://roadclouding.com:7003")

def getAssignedTasks
	assignedTasks = CrawlerTask.where(:carrier => $worker_name)
end

class Rep
  include HTTParty
  format :html
  http_proxy '127.0.0.1', 8087
end

$url_fixedpart = "http://wap.szicity.com/cm/jiaotong/szwxcsTrafficTouch/wap/roadInfo.do?roadid="

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
	begin
		timeStamp = Time.now
		task.crawler_links.each do |road|
		    	$mylogger.info $url_fixedpart+road.href
		    	#puts $url_fixedpart+road.href+road.rn
		    	respHtml = Rep.get($url_fixedpart+road.href)
			doc = Nokogiri::HTML(respHtml)
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
					  direction = direction_lexical specifiedDesc
					  speed = format_speed speedDesc
					  road_traffic = RoadTraffic.find_or_create_by :rn => road.rn, :rid => road.href, :crawler_id => $worker_name, :ts => timeStamp, :ts_in_sec => timeStamp.to_i
					  segment = genSegment_v3 road_traffic, specifiedDesc
					  segment.spd = speed
					  segment.dir = direction
					  segment.duration = duration_lexical durationDesc
					  segment.desc.gsub! /DDDDD/, direction
					  #segment.desc.gsub! /TTTTT/, segment.duration
					  #segment.desc.gsub! /SSSSS/, speed
					  road_traffic.save
				   end
			end
		end
		road_traffics = RoadTraffic.where(:crawler_id => $worker_name, :ts => timeStamp)
		$mylogger.info "done one snap! "+task.snap_ts.to_s
		$mylogger.info "one traffic generated for "+road_traffics.to_json
		#puts road_traffics.to_json
		$outbound2local.send_string road_traffics.to_json if road_traffics.size>0
		$outbound2rc.send_string road_traffics.to_json if road_traffics.size>0
		$new_outbound2local.send_string road_traffics.to_json if road_traffics.size>0
		$new_outbound2rc.send_string road_traffics.to_json if road_traffics.size>0
	rescue 
		$mylogger.error "some errors happened:" + $!.to_s
		return
	end
end

loop do
	$mylogger.debug "in loop "+$worker_name
	msg = ""
	task_list = getAssignedTasks
	$mylogger.debug task_list.to_json if task_list
	task_list.each do |task|
		fetchTrafficAndSave(task)
		task.destroy
	end
	sleep 60
end