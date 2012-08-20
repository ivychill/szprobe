#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)

$mylogger = Logger.new File.expand_path("../../log/traffic_crawler_master.log", __FILE__)
context = ZMQ::Context.new(1)
inbound = context.socket(ZMQ::ROUTER)
inbound.bind("ipc://traffic.ipc")

loop do
	$mylogger.debug "in traffic-crawler-master loop"
	snap = inbound.recv
	$mylogger.debug snap
	if snap
		#split snap to 10 pieces, put it to task table accordingly
		#if snap.
	end
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

def trafficCrawler(road, roadlink)
	begin
		respHtml = Rep.get(roadlink)
		doc = Nokogiri::HTML(respHtml)
		doc.css("div.auto300 table tbody").each do |link|
			wholeDetails = link.css("tr")
			if wholeDetails.size == 3
				road.desc = link.content
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
				road.scopes.create! :direction => direction, :speed => speed, :details => specifiedDesc
				$mylogger.debug "updated "+road.name
			end
		end
	rescue 
		$mylogger.error "some errors happened:" + $!.to_s
	end
	return
end

def fetchAllTraffic
	last_snap = Snap.find(:last)
	#only update the traffic within $interval_between_two_commit 2012/08/14 to be changed
	return if ($last_checked-last_snap.recorded).abs < $interval_between_two_commit
	begin
		last_snap.summaries.each do |road|
		    	next if road.desc
		    	respHtml = Rep.get($url_fixedpart+road.href)
			doc = Nokogiri::HTML(respHtml)
			doc.css("div.auto300 table tbody").each do |link|
				  wholeDetails = link.css("tr")
				  if wholeDetails.size == 3
					  road.desc = link.content
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
					  road.scopes.create! :direction => direction, :speed => speed, :details => specifiedDesc
					  $mylogger.debug "updated "+road.name
				   end
			end
		end
		last_snap.save
		$mylogger.info "done one snap! "+last_snap.recorded.to_s
	rescue 
		$mylogger.error "some errors happened:" + $!.to_s
		last_snap.save if last_snap
		return
	end
end




