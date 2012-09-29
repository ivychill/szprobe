#encoding: utf-8
require File.expand_path("../util_helper", __FILE__)
require 'httparty'
require 'nokogiri'

#2012.09.28 新版有路况的内容
#<!-- 内容区块 begin -->
#<div class="result">	
#    
#
#<div class="gb_wrap">
#	<!-- <div class="chezhu">我的定制 </div>-->
#    <div class="gb_current"><span style="margin-left:0px;">1</span></div>
#</div>
#	<div class="clear"></div>
#	<div class="tfbox" id="gj">
#		
#			<h2 class="tit mb10"><span class="dllb">南山大道</span><em class="fr">发布时间（10:15）</em></h2>
#			<div class="m20">
#				<img src="http://112.95.174.20:8101/msSheduler/image/176x150/output/SZX/S130023.png?id=878688"><br/>
#				<img src="../images/traffic/pic03.png">
#			</div>
#		
#		<h2 class="tit mb10"><span class="mqydlk">南山大道目前拥堵路况</span></h2>
#		
#	    
#			<div class="m10">
#				  
#					<p class="ce50000">同乐方向: 创业路口->桂庙路口</p>
#					<p>速度: 12km/h&#12288;&#12288;通行时间: 3分钟36秒</p>
#				  
#					<p class="ce50000">蛇口方向: 南山公安分局->桃园路口</p>
#					<p>速度: 14km/h&#12288;&#12288;通行时间: 3分钟48秒</p>
#				  
#					<p class="ce50000">蛇口方向: 桃园路口->桂庙路口</p>
#					<p>速度: 13km/h&#12288;&#12288;通行时间: 4分钟16秒</p>
#				
#			</div>
#		
#		<h2 class="tit mb10"><span class="jjspdb">南山大道相关路况视频</span></h2>
#		
#		<div class="m10">
#			
#				<a href="videoPlay.do?mac=062F8A12009D&carmeId=1" onclick="$('#t_15').click();">南山大道玉泉路</a>
#		      		
#		    
#		</div>
#	</div>
#	<div class="clear"></div>
#</div>
#<!-- 内容区块 end -->
#</div>

#2012.09.28无路况内容
#<div class="result">	
#    
#
#<div class="gb_wrap">
#	<!-- <div class="chezhu">我的定制 </div>-->
#    <div class="gb_current"><span style="margin-left:0px;">1</span></div>
#</div>
#	<div class="clear"></div>
#	<div class="tfbox" id="gj">
#		
#			<h2 class="tit mb10"><span class="dllb">深南东路</span><em class="fr">发布时间（10:20）</em></h2>
#			<div class="m20">
#				<img src="http://112.95.174.20:8101/msSheduler/image/176x150/output/SZX/S130030.png?id=131716"><br/>
#				<img src="../images/traffic/pic03.png">
#			</div>
#		
#		<h2 class="tit mb10"><span class="mqydlk">深南东路目前拥堵路况</span></h2>
#		
#		   <div class="nodata">
#		   目前深南东路无堵塞路段，请您保持车速，小心驾驶。
#		   </div>
#	    
#	    
#		<h2 class="tit mb10"><span class="jjspdb">深南东路相关路况视频</span></h2>
#		
#		   <div class="nodata">
#		   深南东路无相关路况视频。
#		   </div>
#	    
#		<div class="m10">
#			
#		</div>
#	</div>
#	<div class="clear"></div>
#</div>
#<!-- 内容区块 end -->
#</div>


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
	#assignedTasks = CrawlerTask.where(:carrier => $worker_name)
	task1 = CrawlerTask.new :carrier => "traffic-crawler-new"
	task1.crawler_links.new :href => "R03012", :rn => "南山大道"
	task1.crawler_links.new :href => "R03020", :rn => "深南东路"
	assignedTasks = [tasks1]
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
	#$mylogger.info task.to_json
	puts task.to_json
	begin
		timeStamp = Time.now
		task.crawler_links.each do |road|
		    	$mylogger.info $url_fixedpart+road.href
		    	#puts $url_fixedpart+road.href+road.rn
		    	respHtml = Rep.get($url_fixedpart+road.href)
			doc = Nokogiri::HTML(respHtml)
		    	#puts doc
			doc.css("div.result tfbox m10").each do |link|
				  puts link
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

#loop do
	#$mylogger.debug "in loop "+$worker_name
	msg = ""
	task_list = getAssignedTasks
#	$mylogger.debug task_list.to_json if task_list
	task_list.each do |task|
		fetchTrafficAndSave(task)
		task.destroy
	end
#	sleep 60
#end